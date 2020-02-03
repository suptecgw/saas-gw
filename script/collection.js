function CCollection() {
    /* --CCollection object-- */
    var lsize = 0;

    this.add = _add;
    this.remove = _remove;
    this.isEmpty = _isEmpty;
    this.size = _size;
    this.clear = _clear;
    this.clone = _clone;
    this.contains = _contains;

    function _add(newItem) {
        /* --adds a new item to the collection-- */
        if (newItem == null) return;

        lsize++;
        this[(lsize - 1)] = newItem;
    }

    function _remove(index) {
        /* --removes the item at the specified index-- */
        if (index < 0 || index > this.length - 1) return;
        this[index] = null;

        /* --reindex collection-- */
        for (var i = index; i <= lsize; i++)
            this[i] = this[i + 1];

        lsize--;
    }

    function _isEmpty() {
        return lsize == 0
    }     /* --returns boolean if collection is/isn't empty-- */

    function _size() {
        return lsize
    }     /* --returns the size of the collection-- */

    function _clear() {
        /* --clears the collection-- */
        for (var i = 0; i < lsize; i++)
            this[i] = null;

        lsize = 0;
    }
     
    function _contains(item){
        for (var i = 0; i < lsize; i++) {
            if (this[i] == item) {
                return true;
            }
        }
        return false;
    }

    function _clone() {
        /* --returns a copy of the collection-- */
        var c = new CCollection();

        for (var i = 0; i < lsize; i++)
            c.add(this[i]);

        return c;
    }
}