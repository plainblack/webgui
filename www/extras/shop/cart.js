/*global window, document, YAHOO */

(function () {
    var $event       = YAHOO.util.Event,
        $connect     = YAHOO.util.Connect,
        $json        = YAHOO.lang.JSON,
        addressCache = {},
        elements     = {
            dropdowns: {
                billing: 'billingAddressId_formId',
                shipping: 'shippingAddressId_formId'
            }
        },
        addressParts = [
            'label', 'firstName', 'lastName', 'organization', 'address1',
            'address2', 'address3', 'city', 'state', 'code', 'country', 
            'phoneNumber', 'email'
        ];

    function omap(o, fn) {
        var r = [], k;
        for (k in o) {
            if (o.hasOwnProperty(k)) {
                r.push(fn.call(o, k, o[k]));
            }
        }
        return r;
    }

    function oeach(o, fn) {
        omap(o, fn);
        return;
    }

    function addAddressKind(name) {
        var i, key, obj = elements[name] = {};
        for (i = 0; i < addressParts.length; i += 1) {
            key = addressParts[i];
            obj[key] = name + '_' + key + '_formId';
        }
    }

    function getDomElements(o) {
        oeach(o, function (k, v) {
            if (typeof v === 'object') {
                getDomElements(v);
            }
            else {
                this[k] = document.getElementById(v);
            }
        });
    }

    function sameChange() {
        var d = elements.same.checked;
        oeach(elements.shipping, function (k, v) {
            v.disabled = d;
        });
        elements.dropdowns.shipping.disabled = d; 
    }

    function updateAddressDropdowns(o) {
        var label   = o.argument.address.label,
            id      = o.responseText;

        function updateOne(dropdown) {
            var options = dropdown.options, i, opt;
            for (i = 0; i < options.length; i += 1) {
                opt = options[i];
                if (opt.text === label) {
                    opt.value = id;
                    return;
                }
            }

            opt = document.createElement('option');
            opt.value = id;
            opt.text  = label;
            dropdown.appendChild(opt);
        }

        updateOne(elements.dropdowns.billing);
        updateOne(elements.dropdowns.shipping);
        elements.dropdowns[o.argument.name].value = id;
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
                copy    = oels.label.value === label,
                cached  = addressCache[label],
                dirty;

            if (!cached) {
                cached = addressCache[label] = {};
            }

            oeach(elements[name], function (k, v) {
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
            oeach(address, function (k, v) {
                var dom = elems[k];
                if (dom) {
                    dom.value = v;
                }
            });
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

    function main() {
        var checks;
        addAddressKind('billing');
        addAddressKind('shipping');
        getDomElements(elements);

        elements.form = document.forms[0];
        checks = elements.form.sameShippingAsBilling;
        elements.same = checks[0];
        $event.on(checks, 'change', sameChange);
        sameChange();

        function handleBlur(name) {
            var values = omap(elements[name], function (k, v) {
                return v;
            });
            $event.on(values, 'focusout', addressChange(name));
        }
        handleBlur('billing');
        handleBlur('shipping');

        function handleDropdown(name) {
            $event.on(elements.dropdowns[name], 'change', addressUpdater(name));
        }

        handleDropdown('billing');
        handleDropdown('shipping');
    }

    $event.onDOMReady(main);
}());
