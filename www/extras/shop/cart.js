/*global _, window, document, YAHOO */

(function () {
    function clone(o) {
        function F() {}
        F.prototype = o;
        return new F();
    }

    function formatCurrency(n) {
        return parseFloat(n.toString()).toFixed(2);
    }

    function validAddress(a) {
        return a.label  &&
            a.firstName &&
            a.lastName  &&
            a.address1  &&
            a.city      &&
            a.state     &&
            a.code      &&
            a.country;
    }

    function addressIdCounts(id) {
        return id &&
            id !== 'new_address' &&
            id !== 'update_address';
    }

    function fillIn(dom, a) {
        _.each(a, function (v, k) {
            if (dom[k]) {
                dom[k].value = v;
            }
        });
    }

    var Cart = {
        attachAddressBlurHandlers: function (name) {
            var fields  = _.values(this.elements[name]),
                handler = this.createAddressBlurHandler(name);
            this.event.on(fields, 'focusout', handler);
        },

        attachAddressSelectHandler: function (name) {
            var e       = this.elements.dropdowns[name],
                handler = this.createAddressFiller(name);

            this.event.on(e, 'change', handler);
        },

        attachPerItemShippingChangeHandler: function (select) {
            this.event.on(select, 'change',
                _.bind(this.setCartItemShippingId, this, select));
        },

        // Updates the total fields based on information already contained in
        // this.prices
        calculateSummary: function () {
            var e            = this.elements,
                prices       = this.prices,
                shipping     = prices.shipping[e.shipper.value],
                shipPrice    = (shipping ?
                    (shipping.hasPrice ?
                        parseFloat(shipping.price) :
                        0)
                    : 0),
                tax          = parseFloat(prices.tax),
                subtotal     = parseFloat(prices.subtotal),
                beforeCredit = tax + subtotal + shipPrice,
                creditAvail  = parseFloat(e.credit.available.innerHTML),
                creditUsed   = Math.min(beforeCredit, creditAvail),
                afterCredit  = beforeCredit - creditUsed;

            e.credit.used.innerHTML = formatCurrency(creditUsed);
            e.total.innerHTML       = formatCurrency(afterCredit);
        },

        computePerItemShippingOptions: function () {
            var self         = this,
                shipping     = this.elements.dropdowns.shipping,
                selectedMain = shipping.value,
                validOptions = _.select(shipping.options, function (o) {
                    var v = o.value;
                    return addressIdCounts(v) &&
                       v !== selectedMain;
                });

            _.each(this.getPerItemShippingDropdowns(), function (d) {
                var selected = d.value;

                _(d.options).chain().filter(function (o) {
                    return o.value;
                }).each(_.bind(d.removeChild, d));

                _.each(validOptions, function (o) {
                    d.appendChild(o.cloneNode(true));
                });

                // The idea here is to reselect the option that was selected,
                // if it's still valid.  If not, we have to tell the backend
                // as well.
                d.value = selected;
                if (d.value !== selected) {
                    d.value = '';
                    self.setCartItemShippingId(d);
                }
            });
        },

        connect: YAHOO.util.Connect,

        copyBilling: function () {
            var self = this,
                e    = this.elements,
                d    = e.dropdowns;
            d.shipping.value = d.billing.value;
            this.getSelectAddress(d.billing, function (address) {
                fillIn(e.shipping, address);
                self.computePerItemShippingOptions();
                self.updateSummary();
            });
        },

        create: function (args) {
            var self = clone(this);
            self.init(args);
        },

        createAddressBlurHandler: function (name) {
            var self  = this,
                other = name === 'billing' ? 'shipping' : 'billing',
                e     = this.elements[name],
                o     = this.elements[other],
                c     = this.addressCache;

            return function () {
                var address = {},
                    label   = e.label.value,
                    copy    = o && o.label.value === label,
                    cache   = c[label],
                    dirty;

                if (!cache) {
                    cache = c[label] = {};
                }

                _.each(e, function (v, k) {
                    v = v.value;
                    address[k] = v;
                    if (cache[k] !== v) {
                        dirty = true;
                        cache[k] = v;
                    }
                    if (copy) {
                        o[k].value = v;
                    }
                });

                if (dirty && validAddress(address)) {
                    self.saveAddress(address, name);
                }
            };
        },

        createAddressFiller: function (name) {
            var self   = this,
                e      = this.elements[name],
                select = this.elements.dropdowns[name];

            return _.bind(this.getSelectAddress, this, select, function (a) {
                fillIn(e, a);
                if (name === 'billing' && self.sameShipping()) {
                    self.copyBilling();
                }
                self.updateSummary();
            });
        },

        dom: YAHOO.util.Dom,

        formatAddress: function (a) {
            var et  = _.template('<a href="mailto:<%= email %>"><%= email %>'),
                csz = _.template('<%= city %>, <%= state %> <%= code %>');

            return _.compact([
                ' ',
                [a.firstName, a.middleName, a.lastName].join(' '),
                a.address1, a.address2, a.address3,
                csz(a),
                a.country,
                a.phone,
                a.email && et(a)
            ]).join('<br />');
        },

        getPerItemShippingDropdowns: function () {
            return this.dom.getElementsByClassName('itemAddressMenu', 'select');
        },

        getSelectAddress: function (select, callback) {
            var self   = this,
                id     = select.value,
                label  = select.options[select.selectedIndex].text,
                c      = this.addressCache,
                cache  = c[label];

            if (cache) {
                callback(cache);
            }
            else {
                this.request('GET', {
                    shop      : 'address',
                    method    : 'ajaxGetAddress',
                    addressId : id
                },
                function (o) {
                    var address = self.json.parse(o.responseText);
                    c[address.label] = address;
                    callback(address);
                });
            }
        },

        event: YAHOO.util.Event,

        init: function (args) {
            // this.elements is our cache of dom objects.  We're passed in an
            // object with ids, and we want to replace those ids with actual
            // dom references.
            function getElements(o) {
                _.each(o, function (v, k) {
                    if (typeof v === 'object') {
                        getElements(v);
                    }
                    else {
                        o[k] = document.getElementById(v);
                    }
                });
            }

            var self   = this,
                e      = args.elements,
                f      = document.forms[0],
                checks = f.sameShippingAsBilling,
                sameChange;

            getElements(e);
            this.elements = e;

            this.prices       = null;
            this.addressCache = {};
            this.baseUrl      = args.baseUrl;
            this.attachAddressBlurHandlers('billing');
            this.attachAddressSelectHandler('billing');

            // if checks is false, we don't have the shipping address form on
            // this page (because none of the items in the cart require
            // shipping)
            if (checks) {
                e.same = checks[0];
                sameChange = _.bind(this.useSameShippingAddressChange, this);
                this.event.on(checks, 'change', sameChange);
                sameChange();
                this.attachAddressBlurHandlers('shipping');
                this.attachAddressSelectHandler('shipping');
                _.each(
                    this.getPerItemShippingDropdowns(),
                    _.bind(self.attachPerItemShippingChangeHandler, self)
                );
                this.event.on(e.dropdowns.shipping, 'change', function () {
                    self.computePerItemShippingOptions();
                });
                self.computePerItemShippingOptions();
            }
            else {
                delete e.shipping;
            }

            this.event.on(e.shipper, 'change',
                this.calculateSummary, null, this);

            this.updateSummary();
        },

        json: YAHOO.lang.JSON,

        saveAddress: function (address, name) {
            var self = this,
                label = address.label;

            this.request('POST', {
                shop    : 'address',
                method  : 'ajaxSave',
                address : this.json.stringify(address)
            },
            function (o) {
                var id = o.responseText,
                     d = self.elements.dropdowns;

                function updateOne(dropdown) {
                    var opt = _.detect(dropdown.options, function (o) {
                        return o.text === label;
                    });

                    if (!opt) {
                        opt = document.createElement('option');
                        opt.text  = label;
                        dropdown.appendChild(opt);
                    }

                    opt.value = id;
                }

                updateOne(d.billing);
                updateOne(d.shipping);
                d[name].value = id;
                if (name === 'billing' && self.sameShipping()) {
                    self.copyBilling();
                }
                else {
                    self.computePerItemShippingOptions();
                }
                self.updateSummary();
            });
        },

        // Like calling calculateSummary, except that it will first fetch
        // price information from the server.  This should be called when the
        // address information has changed, and at least once on page load (so
        // we have an initial this.prices to work with)
        updateSummary: function () {
            var self     = this,
                e        = this.elements,
                tax      = e.tax,
                shipper  = e.shipper,
                selected = shipper.value,
                d        = e.dropdowns,
                shipping = d.shipping.value,
                billing  = d.billing.value,
                params   = {
                    shop: 'cart',
                    method: 'ajaxPrices'
                };

            if (addressIdCounts(billing)) {
                params.billingId = billing;
            }

            if (this.sameShipping()) {
                params.shippingId = params.billingId;
            } else if (addressIdCounts(shipping)) {
                params.shippingId = shipping;
            }

            this.request('GET', params, function (o) {
                var response = self.json.parse(o.responseText);

                if (response.error) {
                    return;
                }

                self.prices   = response;
                tax.innerHTML = formatCurrency(response.tax);

                _(shipper.options).chain().select(function (o) {
                    return o.value;
                }).each(function (o) {
                    o.parentNode.removeChild(o);
                });

                _.each(response.shipping, function (o, id) {
                    var opt   = document.createElement('option'),
                        label = o.label;

                    if (o.hasPrice) {
                        label += ' (' + formatCurrency(o.price) + ')';
                    }

                    opt.innerHTML = label;
                    opt.value     = id;
                    shipper.appendChild(opt);
                });

                shipper.value = selected;
                self.calculateSummary();
            });
        },

        // This is a very thin layer on top of YAHOO.util.Connect.asyncRequest.
        request: function (method, params, success) {
            var url   = this.baseUrl,
                cb    = { success: success },
                query = _(params).map(function (v, k) {
                    return [k, v].join('=');
                }).join('&');

            if (method === 'GET') {
                this.connect.asyncRequest(method, url + '?' + query, cb);
            }
            else {
                this.connect.asyncRequest(method, url, cb, query);
            }
        },

        sameShipping: function () {
            return this.elements.same.checked;
        },

        setCartItemShippingId: function (select) {
            var self = this, parent = select.parentNode;

            function setText(t) {
                parent.innerHTML = t;
                parent.insertBefore(select, parent.firstChild);
            }

            this.request('POST', {
                shop      : 'cart',
                method    : 'ajaxSetCartItemShippingId',
                itemId    : select.id.match(/itemAddress_(.*)_formId/)[1],
                addressId : select.value
            }, function () {
                self.updateSummary();
                if (select.value) {
                    self.getSelectAddress(select, function (address) {
                        setText(self.formatAddress(address));
                    });
                }
                else {
                    setText('');
                }
            });
        },

        useSameShippingAddressChange: function () {
            var e       = this.elements,
                disable = this.sameShipping(),
                drops   = e.dropdowns;

            _.each(e.shipping, function (v, k) {
                v.disabled = disable;
            });
            drops.shipping.disabled = disable;
            if (disable && addressIdCounts(drops.billing.value)) {
                this.copyBilling();
            }
        }
    },
        addressParts = [
            'label', 'firstName', 'lastName', 'organization',
            'address1', 'address2', 'address3', 'city', 'state',
            'code', 'country', 'phoneNumber', 'email'
        ],
        elements = {
            shipper   : 'shipperId_formId',
            tax       : 'taxWrap',
            total     : 'totalPriceWrap',
            credit    : {
                available : 'inShopCreditAvailableWrap',
                used      : 'inShopCreditDeductionWrap'
            },
            dropdowns : {
                billing : 'billingAddressId_formId',
                shipping: 'shippingAddressId_formId'
            }
        };

    function addAddressKind(name) {
        var obj = elements[name] = {};
        _.each(addressParts, function (key) {
            obj[key] = name + '_' + key + '_formId';
        });
    }

    addAddressKind('billing');
    addAddressKind('shipping');

    Cart.event.onDOMReady(function () {
        Cart.create({
            baseUrl  : window.location.pathname,
            elements : elements
        });
    });
}());
