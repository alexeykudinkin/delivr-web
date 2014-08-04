function redBlackTree() {
    var RED = 1, BLACK = 2;

    function Node(value) {
        this.value = value;
        this.color = BLACK;
        this.left = null;
        this.right = null;
        this.parent = null;
    }

    function is_red(x) {
        return x && x.color == RED;
    }

    function rotate_left(tree, x) {
        var y = x.right;
        x.right = y.left;
        if (y.left) {
            y.left.parent = x;
        }
        y.parent = x.parent;
        if (tree.root == x) {
            tree.root = y;
        } else {
            if (x == x.parent.left) {
                x.parent.left = y;
            } else {
                x.parent.right = y;
            }
        }
        y.left = x;
        x.parent = y;
    }

    function rotate_right(tree, x) {
        var y = x.left;
        x.left = y.right;
        if (y.right) {
            y.right.parent = x;
        }
        y.parent = x.parent;
        if (tree.root == x) {
            tree.root = y;
        } else {
            if (x == x.parent.left) {
                x.parent.left = y;
            } else {
                x.parent.right = y;
            }
        }
        y.right = x;
        x.parent = y;
    }

    function left_most(x) {
        while (x && x.left) {
            x = x.left;
        }
        return x;
    }

    function right_most(x) {
        while (x && x.right) {
            x = x.right;
        }
        return x;
    }

    function successor(x) {
        if (!x) {
            return null;
        }
        if (x.right) {
            return left_most(x.right);
        }
        while (x.parent && x.parent.right == x) {
            x = x.parent;
        }
        return x.parent;
    }

    function predcessor(x) {
        if (!x) {
            return x;
        }
        if (x.left) {
            return right_most(x.left);
        }
        while (x.parent && x.parent.left == x) {
            x = x.parent;
        }
        return x.parent;
    }

    function insert_fixup(tree, x) {
        while (x != tree.root && is_red(x.parent)) {
            if (x.parent == x.parent.parent.left) {
                var y = x.parent.parent.right;
                if (is_red(y)) {
                    x.parent.color = BLACK;
                    y.color = BLACK;
                    y.parent.color = RED;
                    x = y.parent;
                } else {
                    if (x == x.parent.right) {
                        x = x.parent;
                        rotate_left(tree, x);
                    }
                    x.parent.color = BLACK;
                    x.parent.parent.color = RED;
                    rotate_right(tree, x.parent.parent);
                }
            } else {
                var y = x.parent.parent.left;
                if (is_red(y)) {
                    x.parent.color = BLACK;
                    y.color = BLACK;
                    y.parent.color = RED;
                    x = y.parent;
                } else {
                    if (x == x.parent.left) {
                        x = x.parent;
                        rotate_right(tree, x);
                    }
                    x.parent.color = BLACK;
                    x.parent.parent.color = RED;
                    rotate_left(tree, x.parent.parent);
                }
            }
        }
        tree.root.color = BLACK;
    }

    function delete_fixup(tree, x, xparent) {
        while (x != tree.root && !is_red(x)) {
            if (x == xparent.left) {
                var y = xparent.right;
                if (is_red(y)) {
                    y.color = BLACK;
                    xparent.color = RED;
                    rotate_left(tree, xparent);
                    y = xparent.right;
                }
                if (!is_red(y.left) && !is_red(y.right)) {
                    y.color = RED;
                    x = xparent;
                    xparent = xparent.parent;
                } else {
                    if (!is_red(y.right)) {
                        if (y.left) {
                            y.left.color = BLACK;
                        }
                        y.color = RED;
                        rotate_right(tree, y);
                        y = xparent.right;
                    }
                    y.color = xparent.color;
                    xparent.color = BLACK;
                    if (y.right) {
                        y.right.color = BLACK;
                    }
                    rotate_left(tree, xparent);
                    x = tree.root;
                }
            } else {
                var y = xparent.left;
                if (is_red(y)) {
                    y.color = BLACK;
                    xparent.color = RED;
                    rotate_right(tree, xparent);
                    y = xparent.left;
                }
                if (!is_red(y.right) && !is_red(y.right)) {
                    y.color = RED;
                    x = xparent;
                    xparent = xparent.parent;
                } else {
                    if (!is_red(y.left)) {
                        if (y.right) {
                            y.right.color = BLACK;
                        }
                        y.color = RED;
                        rotate_left(tree, y);
                        y = xparent.left;
                    }
                    y.color = x.parent.color;
                    xparent.color = BLACK;
                    if (y.left) {
                        y.left.color = BLACK;
                    }
                    rotate_right(tree, x.parent);
                    x = tree.root;
                }
            }
        }
        if (x) {
            x.color = BLACK;
        }
    }

    function insert_node(tree, x) {
        var node = tree.root, parent = null, cmp = undefined;
        while (node) {
            cmp = tree.cmp(x.value, node.value);
            parent = node;
            node = cmp < 0 ? node.left : node.right;
        }
        x.parent = parent;
        x.color = RED;
        if (parent) {
            if (cmp < 0) {
                parent.left = x;
            } else {
                parent.right = x;
            }
        } else {
            tree.root = x;
        }
        insert_fixup(tree, x);
        tree.size = tree.size + 1;
    }

    function remove_node(tree, z) {
        if (!z.left && !z.right) {
            var parent = z.parent;
            if (parent) {
                if (parent.left == z) {
                    parent.left = null;
                } else {
                    parent.right = null;
                }
                if (!is_red(z)) { 
                    delete_fixup(tree, null, parent);
                }
            } else {
                tree.root = null;
            }
        } else if (!z.left || !z.right) {
            var x = z.left ? z.left : z.right;
            x.parent = z.parent;
            if (z.parent) {
                if (z.parent.left == z) {
                    z.parent.left = x;
                } else {
                    z.parent.right = x;
                }
            } else {
                tree.root = x;
            }
            if (!is_red(z)) {
                delete_fixup(tree, x, z.parent);
            }
        } else {
           var x = left_most(z.right);
           var c = x.color;
           x.color = z.color
           z.color = c;
           if (x == z.right) {
               x.left = z.left;
               x.parent = z.parent;
               z.left.parent = x;
               if (z.parent) {
                   if (z.parent.left == z) {
                       z.parent.left = x;
                   } else {
                       z.parent.right = x;
                   }
               } else {
                   tree.root = x;
               }
               if (!is_red(z)) {
                   delete_fixup(tree, x.right, x);
               }
           } else {
               var xparent = x.parent;
               xparent.left = null;
               x.parent = z.parent;
               if (z.parent) {
                   if (z.parent.left == z) {
                       z.parent.left = x;
                   } else {
                       z.parent.right = x;
                   }
               } else {
                   tree.root = x;
               }
               x.left = z.left;
               z.left.parent = x;
               x.right = z.right;
               z.right.parent = x;
               if (!is_red(z)) {
                   delete_fixup(tree, null, xparent);
               }
           }
        }
        tree.size = tree.size - 1;
    }

    function Iterator(t, n) {
        this._impl = { tree: t, node: n };
    }

    Iterator.prototype.clone = function() {
        return new Iterator(this._impl.tree, this._impl.node);
    }

    Iterator.prototype.next = function () {
        this._impl.node = successor(this._impl.node);
    }

    Iterator.prototype.prev = function () {
        if (!this._impl.node) {
            this._impl.node = right_most(this._impl.tree.root);
        }
        this._impl.node = predcessor(this._impl.node);
    }

    Iterator.prototype.equal = function (iter) {
        return this._impl.tree === iter._impl.tree &&
               this._impl.node === iter._impl.node;
    }

    Iterator.prototype.erase = function () {
        var next = successor(this._impl.node);
        remove_node(this._impl.tree, this._impl.node);
        this._impl.node.left = null;
        this._impl.node.right = null;
        this._impl.node.parent = null;
        this._impl.node = next;
    }

    Iterator.prototype.value = function () {
        return this._impl.node && this._impl.node.value;
    }

    function Tree(comparator) {
        this._impl = {
            root: null,
            size: 0,
            cmp: comparator
        };
    }

    Tree.prototype.begin = function () {
        return new Iterator(this._impl, left_most(this._impl.root));
    }

    Tree.prototype.end = function () {
        return new Iterator(this._impl, null);
    }

    Tree.prototype.lowerBound = function (value) {
        var parent = null, current = this._impl.root;
        while (current) {
            if (this._impl.cmp(current.value, value) >= 0) {
                parent = current;
                current = current.left;
            } else {
                current = current.right;
            }
        }
        return new Iterator(this._impl, parent);
    }

    Tree.prototype.upperBound = function (value) {
        var parent = null, current = this._impl.root;
        while (current) {
            if (this._impl.cmp(value, current.value) < 0) {
                parent = current;
                current = current.left;
            } else {
                current = current.right;
            }
        }
        return new Iterator(this._impl, parent);
    }

    Tree.prototype.lookup = function (value) {
        var iter = this.upperBound(value);
        if (this._impl.cmp(iter.value(), value) == 0) {
            return iter;
        }
        return this.end();
    }

    Tree.prototype.insert = function (value) {
        var node = new Node(value);
        insert_node(this._impl, node);
        return new Iterator(this._impl, node);
    }

    Tree.prototype.insertUnique = function (value) {
        var iter = this.lookup(value);
        if (iter.equal(this.end())) {
            return this.insert(value);
        }
        return iter;
    }

    Tree.prototype.size = function () {
        return this._impl.size;
    }

    Tree.prototype.empty = function () {
        return this.size() == 0;
    }

    return {
        SearchTree: Tree,

        eraseAll: function (first, last) {
            if (first._impl.tree != last._impl.tree) {
                throw Error("Iterators are not belong to same tree");
            }
            while (!first.equal(last)) {
                first.erase();
            }
        },

        next: function (iter) {
            var copy = iter.clone();
            copy.next();
            return copy;
        },

        prev: function (iter) {
            var copy = iter.clone();
            copy.prev();
            return copy;
        }
    };
}



(function () {
    var bst = redBlackTree();
    function PriorityQueue(comparator) { this.tree = new bst.SearchTree(comparator); }
    PriorityQueue.prototype.size = function () { return this.tree.size(); }
    PriorityQueue.prototype.empty = function () { return this.tree.empty(); }
    PriorityQueue.prototype.erase = function (value) {
        var it = this.tree.lookup(value);
        if (!it.equal(this.tree.end()))
            it.erase();
    }
    PriorityQueue.prototype.push = function (value) { this.tree.insert(value); }
    PriorityQueue.prototype.pop = function () {
        if (this.tree.empty())
            throw Error("PriorityQueue is empty!");
        var it = this.tree.begin();
        var value = it.value(); it.erase();
        return value;
    }

    function buildGraph(distance, waypoints, timeStep) {
        var referenceTime = waypoints[0].from;
        var graph = {};

        function makeEdge(origin, destination, duration) {
            var times = (graph[origin.index] || {});
            var neigh = (times[destination.time] || []);
            neigh.push({ destination: destination, duration: duration });
            times[origin.time] = neigh;
            graph[origin.index] = times;
        }

        function roundDown(time) {
            return referenceTime + timeStep *
                Math.floor((time - referenceTime)/timeStep);
        }

        function roundUp(time) {
            return referenceTime + timeStep *
                Math.ceil((time - referenceTime)/timeStep);
        }

        for (var origin = 0; origin != waypoints.length; ++origin) {
            for (var currentTime = roundDown(waypoints[origin].from);
                       currentTime <= waypoints[origin].to; currentTime += timeStep) {

                makeEdge({ index: origin, time: currentTime },
                         { index: origin, time: currentTime + timeStep }, 0);
                
                for (var destination = 0; destination < waypoints.length; ++destination) {
                    if (origin == destination)
                        continue;

                    var duration = distance(origin, destination);
                    var destinationTime = roundUp(currentTime + duration);
                    if (destinationTime > roundUp(waypoints[destination].to) ||
                          destinationTime < roundDown(waypoints[destination].from)) {
                        continue;
                    }

                    makeEdge({ index: origin, time: currentTime },
                             { index: destination, time: destinationTime },
                             duration);
                }
            }
        }

        return graph;
    }

    function findRoute(distance, waypoints, timeStep) {
        var distances = {};

        function updateDistance(waypoint, duration, previous) {
            var masks = distances[waypoint.index] || {};
            var times = masks[waypoint.mask] || {};
            times[waypoint.time] = { duration: duration, previous: previous };
            masks[waypoint.mask] = times; 
            distances[waypoint.index] = masks;
        }

        function distanceTo(waypoint) {
            return distances[waypoint.index] && distances[waypoint.index][waypoint.mask] &&
                   distances[waypoint.index][waypoint.mask][waypoint.time];
        }

        function durationTo(waypoint) {
            var distance = distanceTo(waypoint);
            return distance && distance.duration;
        }

        function previousWaypoint(waypoint) {
            var distance = distanceTo(waypoint);
            return distance && distance.previous;
        }

        function restorePath(waypoint) {
            var path = []
            while (waypoint) {
                path.push({
                    index: waypoint.index,
                    time: waypoint.time
                });
                var previous = previousWaypoint(waypoint);
                while (previous) {
                    if (previous.index != waypoint.index)
                        break;
                    previous = previousWaypoint(previous);
                }
                waypoint = previous;
            }
            return path.reverse();
        }

        function compareMasks(lhs, rhs) {
            function countOnes(mask) {
                var count = 0;
                while (mask) {
                    if (mask % 2 == 1) ++count;
                    mask = Math.floor(mask / 2);
                }
                return count;
            }
            return countOnes(lhs) - countOnes(rhs);
        }

        function compare(origin, destination) {
            return (origin.time - destination.time) ||
                   (durationTo(originDistance) - durationTo(destinationDistance)) ||
                   compareMasks(origin.mask, destination.mask) ||
                   (origin.index - destination.index);
        }

        var origin = {
            index: 0,
            mask: Math.pow(2, waypoints.length) - 2,
            time: waypoints[0].from
        };

        updateDistance(origin, 0, null);
        var bestPathEnd = origin;

        var graph = buildGraph(distance, waypoints, timeStep);
        var queue = new PriorityQueue(compare);
        queue.push(origin);

        while (!queue.empty()) {
            var origin = queue.pop();
            if (compareMasks(bestPathEnd, origin) > 0)
                bestPathEnd = origin;
            if (bestPathEnd.mask == 0)
                break;
            (graph[origin.index][origin.mask] || []).forEach(function (edge, index, array) {
                var destination = {
                    index: edge.destination.index,
                    time: edge.destination.time,
                    mask: origin.mask & (~(1 << edge.destination.index))
                };
                var newDuration = edge.duration + durationTo(origin);
                var oldDuration = durationTo(destination);
                if (!oldDuration || oldDuration > newDuration) {
                    if (oldDuration)
                        queue.erase(destination);

                    updateDistance(destination, newDuration, origin);
                    queue.push(destination);
                }
            });
        }

        return restorePath(bestPathEnd);
    }

    var distanceService = new google.maps.DistanceMatrixService();
    function solveTsp(waypoints, timeStep, onFinish) {
        function solveImpl() {
            var positions = waypoints.map(function (value, index, array) {
                return value.location;
            });
            distanceService.getDistanceMatrix({
                origins: positions,
                destinations: positions,
                travelMode: google.maps.TravelMode.DRIVING,
                avoidHighways: false,
                avoidTolls: false
            },
            function (response, status) {
                function distance(origin, destination) {
                    return Math.floor(response.rows[origin].elements[destination].duration.value / 60);
                }

                console.log("getDistanceMatrix call returned status " + status);

                if (status != "OK") {
                    var error = "Google Distance Matrix Service returned status " + status;
                    console.log(error);
                    onFinish([], error);
                    return;
                }

                var path = findRoute(distance, waypoints, timeStep);
                if (!path || path.length == 0) {
                    var error = "Cannot find suitable route (empty route returned)";
                    console.log(error);
                    onFinish([], error);
                    return;
		}

                onFinish(path.map(function (value, index, array) {
                    return {
                        waypoint: waypoints[value.index],
                        time: value.time
                    };
                }), "OK");
            });
        }
        solveImpl();
    }

    window.solveTsp = solveTsp;
}())
