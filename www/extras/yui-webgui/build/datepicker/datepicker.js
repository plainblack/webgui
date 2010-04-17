YAHOO.namespace('WebGUI.Form');
YAHOO.WebGUI.Form.DatePicker = {
    init: function() {
        YAHOO.WebGUI.Form.DatePicker.i18n = new WebGUI.i18n({
            namespaces : {
                'WebGUI' : [
                    'submit',
                    'cancel',
                ],
                'Form_Date' : [
                    'Choose a date',
                    'Invalid year'
                ],
                'DateTime' : [
                    'Month',           'Year',
                    'january',         'july',     
                    'february',        'august',   
                    'march',           'september',
                    'april',           'october',  
                    'may',             'november', 
                    'june',            'december', 
                    'january short',   'july short',     
                    'february short',  'august short',   
                    'march short',     'september short',
                    'april short',     'october short',  
                    'may short',       'november short', 
                    'june short',      'december short', 
                    'monday',          'monday med',    'monday short',    'monday 1char',
                    'tuesday',         'tuesday med',   'tuesday short',   'tuesday 1char',
                    'wednesday',       'wednesday med', 'wednesday short', 'wednesday 1char',
                    'thursday',        'thursday med',  'thursday short',  'thursday 1char',
                    'friday',          'friday med',    'friday short',    'friday 1char',
                    'saturday',        'saturday med',  'saturday short',  'saturday 1char',
                    'sunday',          'sunday med',    'sunday short',    'sunday 1char'
                ]
            },
            onpreload  : {
                fn       : YAHOO.WebGUI.Form.DatePicker.postinit,
                obj      : this,
                override : true
            }
        });
    },
    postinit: function() {
        this.time = {};
        this.codeSelect = false;
        var container = document.createElement('div');
        YAHOO.util.Dom.setStyle(container, 'font-size', '9pt');
        YAHOO.util.Dom.setStyle(container, 'position', 'absolute');
        YAHOO.util.Dom.setStyle(container, 'top', '0');
        YAHOO.util.Dom.addClass(container, 'yui-skin-sam');
        document.body.appendChild(container);
        var cal = document.createElement('div');
        YAHOO.util.Dom.generateId(cal);
        YAHOO.util.Dom.setStyle(cal, 'display', 'none');
        container.appendChild(cal);
        var i18n = YAHOO.WebGUI.Form.DatePicker.i18n;
        var config = {
            title: i18n.get('Form_Date', 'Choose a date'),
            close: true,
            DATE_FIELD_DELIMITER: '-',
            DATE_RANGE_DELIMITER: '/',
            MDY_YEAR_POSITION: 1,
            MDY_MONTH_POSITION: 2,
            MDY_DAY_POSITION: 3,
            START_WEEKDAY: getWebguiProperty('firstDayOfWeek'),
            WEEKDAYS_LONG: [
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'sunday'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'monday'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'tuesday'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'wednesday'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'thursday'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'friday'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'saturday')
            ],
            WEEKDAYS_MEDIUM: [
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'sunday med'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'monday med'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'tuesday med'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'wednesday med'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'thursday med'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'friday med'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'saturday med')
            ],
            WEEKDAYS_SHORT: [
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'sunday short'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'monday short'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'tuesday short'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'wednesday short'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'thursday short'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'friday short'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'saturday short')
            ],
            WEEKDAYS_1CHAR: [
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'sunday 1char'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'monday 1char'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'tuesday 1char'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'wednesday 1char'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'thursday 1char'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'friday 1char'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'saturday 1char')
            ],
            MONTHS_SHORT: [
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'january short'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'february short'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'march short'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'april short'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'may short'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'june short'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'july short'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'august short'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'september short'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'october short'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'november short'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'december short')
            ],
            MONTHS_LONG: [
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'january'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'february'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'march'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'april'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'may'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'june'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'july'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'august'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'september'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'october'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'november'),
                YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime', 'december')
            ],
            NAVIGATOR: {
                strings : {
                    'submit'      : YAHOO.WebGUI.Form.DatePicker.i18n.get('WebGUI',    'submit'),
                    'cancel'      : YAHOO.WebGUI.Form.DatePicker.i18n.get('WebGUI',    'cancel'),
                    'month'       : YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime',  'Month'),
                    'year'        : YAHOO.WebGUI.Form.DatePicker.i18n.get('DateTime',  'Year'),
                    'invalidYear' : YAHOO.WebGUI.Form.DatePicker.i18n.get('Form_Date', 'Invalid year')
                }
            }
        };
        this.calendar = new YAHOO.widget.Calendar(null, cal, config);
        this.calendar.selectEvent.subscribe(this.handleSelect, this, true);
        this.calendar.beforeShowEvent.subscribe(this.handleBeforeShow, this, true);
        this.calendar.showEvent.subscribe(this.handleShow, this, true);
        this.calendar.beforeHideEvent.subscribe(this.handleHide, this, true);
        this.calendar.renderEvent.subscribe(this.handleRender, this, true);
        this.calendar.render();
    },
    handleRender: function(e) {
        if ( this.useTime ) {
            this.addTimeBox();
        }
    },
    addTimeBox: function(e) {
            this.timediv = document.createElement('div');
            YAHOO.util.Dom.setStyle(this.timediv, 'text-align', 'center');
            this.calendar.oDomContainer.appendChild(this.timediv);
            this.timediv.appendChild(document.createTextNode('Time: '));
            this.hourEl = document.createElement('input');
            this.hourEl.value = this.hour;
            this.hourEl.setAttribute('size', 2);
            this.hourEl.setAttribute('maxlength', 2);
            this.timediv.appendChild(this.hourEl);
            this.timediv.appendChild(document.createTextNode(' : '));
            this.minuteEl = document.createElement('input');
            this.minuteEl.value = this.min;
            this.minuteEl.setAttribute('size', 2);
            this.minuteEl.setAttribute('maxlength', 2);
            this.timediv.appendChild(this.minuteEl);
            this.secEl = document.createElement('input');
            this.secEl.value = this.sec;
            this.secEl.setAttribute('size', 2);
            this.secEl.setAttribute('maxlength', 2);
            YAHOO.util.Dom.setStyle(this.secEl, 'display', 'none');
            this.timediv.appendChild(this.secEl);
            this.calendar.oDomContainer.appendChild(this.timediv);
            this.timeBoxAdded = true;
            YAHOO.util.Event.on(this.hourEl, 'change', this.handleTimebox, [this.hourEl, 'hour'], this);
            YAHOO.util.Event.on(this.minuteEl, 'change', this.handleTimebox, [this.minuteEl, 'minute'], this);
    },
    handleTimebox: function(e, obj) {
        var input = obj[0];
        var type = obj[1];
        var val = parseInt(input.value);
        if (type == 'hour'){
            this.hour = val;
        }
        if (type == 'minute'){
            this.min = val;
        }
        if (!val)
            val = 0;
        val = val % (type == 'hour' ? 24 : 60);
        input.value = (val < 10 ? '0' : '') + val;
    },
    handleBeforeShow: function(e) {
        if ( this.useTime && !this.timeBoxAdded) {
            this.addTimeBox();
        }
        YAHOO.util.Event.on(this.inputBox, 'change', this.handleChange, this, true);
        this.handleChange();
    },
    handleShow: function(e) {
        var pos = YAHOO.util.Dom.getRegion(this.inputBox);
        YAHOO.util.Dom.setXY(this.calendar.oDomContainer, [pos.left, pos.bottom]);
        YAHOO.util.Dom.setStyle(this.calendar.oDomContainer,'z-index',100);
        YAHOO.util.Dom.setStyle(this.timediv, 'display', ( this.useTime ? 'block' : 'none'));
    },
    handleHide: function(e) {
        YAHOO.util.Event.removeListener(this.inputBox, 'change', this.handleChange);
    },
    handleSelect: function(e) {
        var sel = this.calendar.getSelectedDates()[0];
        var month = sel.getMonth() + 1;
        var day = sel.getDate();
        var year = sel.getFullYear();
        this.inputBox.value = '' + (month < 10 ? '0' : '') + month + '-' + (day < 10 ? '0' : '') + day + '-' + year;
        this.inputBox.value = year + '-' + (month < 10 ? '0' : '') + month + '-' + (day < 10 ? '0' : '') + day;
        if (this.useTime) {
            var hour = 1 * this.hourEl.value;
            var minute = 1 * this.minuteEl.value;
            var sec = 1 * this.secEl.value;
            this.inputBox.value += ' ' + (hour < 10 ? '0' : '') + hour + ':' + (minute < 10 ? '0' : '') + minute + ':' + (sec < 10 ? '0' : '') + sec;
        }
        if (!this.codeSelect) {
            this.calendar.hide();
        }
    },
    display: function(el, time) {
        this.calendar.hide();
        this.inputBox = YAHOO.util.Dom.get(el);
        this.useTime = time;
        this.calendar.show();
    },
    handleChange: function(e) {
        if ((this.inputBox.value != "") && (!this.codeSelect)) {
            this.codeSelect = true;
            var date;
            var res;
            if(res = this.inputBox.value.match(/(\d+)-(\d+)-(\d+)(?: (\d+):(\d+):(\d+))?/)) {
                date = res[1] + '-' + res[2] + '-' + res[3];
                if (res[4]) {
                    this.hour = (res[4] < 10 ? '0' : '') + (1 * res[4]);
                    this.min  = (res[5] < 10 ? '0' : '') + (1 * res[5]);
                    this.sec  = (res[6] < 10 ? '0' : '') + (1 * res[6]);
                }
            }
            if (!this.hour)
                this.hour = '00';
            if (!this.min)
                this.min = '00';
            if (!this.sec)
                this.sec = '00';
            if (this.useTime) {
                this.hourEl.value   = this.hour;
                this.minuteEl.value = this.min;
                this.secEl.value    = this.sec;
            }
            this.calendar.select(date);
            var selectedDates = this.calendar.getSelectedDates();
            if (selectedDates.length > 0) {
                var firstDate = selectedDates[0];
                this.calendar.cfg.setProperty("pagedate", (firstDate.getMonth()+1) + "-" + firstDate.getFullYear());
                this.calendar.render();
            }
            this.codeSelect = false;
        }
    }
};
YAHOO.util.Event.onDOMReady(YAHOO.WebGUI.Form.DatePicker.init, YAHOO.WebGUI.Form.DatePicker, true);

