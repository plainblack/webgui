/*global _, window, document, YAHOO */

(function () {
    var $event       = YAHOO.util.Event,
        $connect     = YAHOO.util.Connect,
        $json        = YAHOO.lang.JSON,
        prices       = null,
        addressCache = {},
        elements     = {
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
        },
        addressParts = [
            'label', 'firstName', 'lastName', 'organization', 'address1',
            'address2', 'address3', 'city', 'state', 'code', 'country',
            'phoneNumber', 'email'
        ];

    function formatCurrency(n) {
        return parseFloat(n.toString()).toFixed(2);
    }

    function addAddressKind(name) {
        var obj = elements[name] = {};
        _.each(addressParts, function (key) {
            obj[key] = name + '_' + key + '_formId';
        });
    }

    function getDomElements(o) {
        _.each(o, function (v, k) {
            if (typeof v === 'object') {
                getDomElements(v);
            }
            else {
                o[k] = document.getElementById(v);
            }
        });
    }

    function sameChange() {
        var d = elements.same.checked;
        _.each(elements.shipping, function (v, k) {
            v.disabled = d;
        });
        elements.dropdowns.shipping.disabled = d;
    }

    function calculateSummary() {
        var shipping     = prices.shipping[elements.shipper.value],
            shipPrice    = (shipping ?
                (shipping.hasPrice ?
                    parseFloat(shipping.price) :
                    0)
                : 0),
            tax          = parseFloat(prices.tax),
            subtotal     = parseFloat(prices.subtotal),
            beforeCredit = tax + subtotal + shipPrice,
            creditAvail  = parseFloat(elements.credit.available.innerHTML),
            creditUsed   = Math.min(beforeCredit, creditAvail),
            afterCredit  = beforeCredit - creditUsed;

        elements.credit.used.innerHTML = formatCurrency(creditUsed);
        elements.total.innerHTML = formatCurrency(afterCredit);
    }

    function updatePrices() {
        var selectedShipper = elements.shipper.value,
            shipping        = elements.dropdowns.shipping.value,
            billing         = elements.dropdowns.billing.value,
            shipper         = elements.shipper,
            url             = window.location.pathname +
                '?shop=cart;method=ajaxPrices;' +
                ( shipping === 'new_address' ?
                  '' : 'shippingId=' + shipping) +
                ( billing === 'new_address' ?
                  '' : 'billingId=' + billing);
            cb = {
                success: function (o) {
                    var response = $json.parse(o.responseText);
                    if (response.error) {
                        return;
                    }
                    prices = response;
                    elements.tax.innerHTML = formatCurrency(response.tax);
                    _(shipper.options)
                        .chain()
                        .map(_.identity)
                        .each(function (o) {
                            if (o.value) {
                                o.parentNode.removeChild(o);
                            }
                        });
                    _.each(response.shipping, function (o, id) {
                        var opt = document.createElement('option'),
                            label = o.label;
                        if (o.hasPrice) {
                            label += ' (' + formatCurrency(o.price) + ')';
                        }
                        opt.innerHTML = label;
                        opt.value = id;
                        shipper.appendChild(opt);
                    });
                    shipper.value = selectedShipper;
                    calculateSummary();
                }
            };
        $connect.asyncRequest('GET', url, cb);
    }

    function updateAddressDropdowns(o) {
        var label   = o.argument.address.label,
            id      = o.responseText;

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

        updateOne(elements.dropdowns.billing);
        updateOne(elements.dropdowns.shipping);
        elements.dropdowns[o.argument.name].value = id;
        updatePrices();
    }

    function saveAddress(a, name) {
        var cb = {
            success: updateAddressDropdowns,
            argument: { address: a, name: name }
        },
            post = 'shop=address;method=ajaxSave;address=' +
                $json.stringify(a),
            url = window.location.pathname;

        $connect.asyncRequest('POST', url, cb, post);
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

    function addressChange(name) {
        var other = name === 'billing' ? 'shipping' : 'billing';
        return function () {
            var address = {},
                els     = elements[name],
                label   = els.label.value,
                oels    = elements[other],
                copy    = oels && oels.label.value === label,
                cached  = addressCache[label],
                dirty;

            if (!cached) {
                cached = addressCache[label] = {};
            }

            _.each(elements[name], function (v, k) {
                v = v.value;
                address[k] = v;
                if (cached[k] !== v) {
                    dirty = true;
                    cached[k] = v;
                }
                if (copy) {
                    oels[k].value = v;
                }
            });
            if (dirty && validAddress(address)) {
                saveAddress(address, name);
            }
        };
    }

    function addressUpdater(name) {
        var elems = elements[name];
        function update(address) {
            _.each(address, function (v, k) {
                var dom = elems[k];
                if (dom) {
                    dom.value = v;
                }
            });
            updatePrices();
        }
        return function () {
            var id     = this.value,
                label  = this.options[this.selectedIndex].text,
                cached = addressCache[label],
                url, cb;

            if (cached) {
                return update(cached);
            }

            url = window.location.pathname +
                '?shop=address;method=ajaxGetAddress;addressId=' +
                id;

            cb = {
                success: function (o) {
                    var address = $json.parse(o.responseText);
                    addressCache[address.label] = address;
                    update(address);
                }
            };
            $connect.asyncRequest('GET', url, cb);
        };
    }

    function handleBlur(name) {
        $event.on(_.values(elements[name]), 'focusout', addressChange(name));
    }

    function handleDropdown(name) {
        $event.on(elements.dropdowns[name], 'change', addressUpdater(name));
    }

    function main() {
        var checks;
        addAddressKind('billing');
        addAddressKind('shipping');
        getDomElements(elements);

        elements.form = document.forms[0];

        handleBlur('billing');
        handleDropdown('billing');

        checks = elements.form.sameShippingAsBilling;
        if (checks) {
            elements.same = checks[0];
            $event.on(checks, 'change', sameChange);
            sameChange();
            handleBlur('shipping');
            handleDropdown('shipping');
        }
        else {
            delete elements.shipping;
        }

        $event.on(elements.shipper, 'change', calculateSummary);
        updatePrices();
    }

    $event.onDOMReady(main);
}());
