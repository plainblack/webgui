/****************************************************************

	Simple row model enabling paged data display in a grid.

*****************************************************************/

if (!Active.Rows) {Active.Rows = {}}

Active.Rows.Page = Active.System.Model.subclass();

Active.Rows.Page.create = function(){

	var obj = this.prototype;

	obj.defineProperty("count", function(){return this.$owner.getProperty("data/count")});
	obj.defineProperty("index", function(i){return i});
	obj.defineProperty("order", function(i){return this._orders ? this._orders[i] : i});
	obj.defineProperty("text", function(i){return this.getOrder(i) + 1});
	obj.defineProperty("image", "none");

	obj.defineProperty("pageSize", 10);
	obj.defineProperty("pageNumber", 0);
	obj.defineProperty("pageCount", function(){return Math.ceil(this.getCount()/this.getPageSize())});

	var getValue = function(i){
		var size = this.getPageSize();
		var number = this.getPageNumber();
		var offset = size * number;
		return this._sorted ? this._sorted[offset + i] : offset + i;
	}

	obj.defineProperty("value", getValue);

	var getValues = function(){
		var size = this.getPageSize();
		var number = this.getPageNumber();
		var offset = size * number;
		var count = this.getCount();
		var max = count > size + offset ? size : count - offset;
		var i, values = [];
		if (this._sorted){
			values = this._sorted.slice(offset, offset + max);
		}
		else {
			for(i=0; i<max; i++){
				values[i] = i + offset;
			}
		}
		return values;
	}

	obj.defineProperty("values", getValues);

	obj.sort = function(index){
		var i, count = this.getCount();
		if (!this._sorted){
			this._sorted = [];
			for(i=0; i<count; i++){
				this._sorted[i] = i;
			}
		}

		var a = {}, direction = "ascending";
		var rows = this._sorted;

		if (this.$owner.getSortProperty("index") == index) {
			if (this.$owner.getSortProperty("direction") == "ascending") {direction = "descending"}
			rows.reverse();
		}
		else {
			for (i=0; i<rows.length; i++) {
				var text = "" + this.$owner.getDataProperty("value", rows[i], index);
				var value = Number(text.replace(/[ ,%\$]/gi, "").replace(/\((.*)\)/, "-$1"));
				a[rows[i]] = isNaN(value) ? text.toLowerCase() + " " : value;
			}
			rows.sort(function(x,y){return a[x] > a[y] ? 1 : (a[x] == a[y] ? 0 : -1)});
		}

		this._sorted = rows;

		this._orders = [];
		for(i=0; i<rows.length; i++){
			this._orders[rows[i]] = i;
		}

		this.setPageNumber(0);
		this.$owner.setSortProperty("index", index);
		this.$owner.setSortProperty("direction", direction);

	}
}

Active.Rows.Page.create();

