var tspSolver = angular.module('tspSolver', ['environmentServices', 'algorithms']);

tspSolver.factory('DjTspSolver', ['Distance', 'DataStructures', function (Distance, DataStructures) {
    function makeEdge(origin, destination, duration) {
        var times = (graph[origin.index] || {});
        var neigh = (times[destination.time] || []);
        neigh.push({ destination: destination, duration: duration });
        times[origin.time] = neigh;
        graph[origin.index] = times;
    }

    function buildGraph(distance, points, timeStep) {
        var referenceTime = points[0].from;
        var graph = {};

        function makeEdge(origin, destination, duration) {
            var times = (graph[origin.index] || {});
            var neigh = (times[origin.time] || []);
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

        points.forEach(function (point, origin) {
            for (var currentTime = roundDown(point.from);
                       currentTime <= point.to; currentTime += timeStep) {

                makeEdge({ index: origin, time: currentTime },
                         { index: origin, time: currentTime + timeStep },
                         (origin == 0 ? 0 : timeStep));
                
                for (var destination = 0; destination != points.length; ++destination) {
                    if (origin == destination)
                        continue;

                    var duration = distance(origin, destination);
                    var destinationTime = roundUp(currentTime + duration);
                    if (destinationTime > roundUp(points[destination].to) ||
                          destinationTime < roundDown(points[destination].from))
                        continue;

                    makeEdge({ index: origin, time: currentTime },
                             { index: destination, time: destinationTime },
                             destinationTime - currentTime);
                };
            }
        });

        return graph;
    }

    function findRoute(distance, points, timeStep) {
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
                    point: points[waypoint.index],
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
            return durationTo(origin) - durationTo(destination) ||
                   origin.time - destination.time ||
                   origin.index - destination.index;
        }

        var origin = {
            index: 0,
            mask: Math.pow(2, points.length) - 2,
            time: points[0].from
        };

        updateDistance(origin, 0, null);
        var bestPathEnd = origin;

        var graph = buildGraph(distance, points, timeStep);
        var queue = new DataStructures.PriorityQueue(compare);
        queue.push(origin);

        while (!queue.empty()) {
            var origin = queue.pop();
            if (compareMasks(bestPathEnd.mask, origin.mask) > 0)
                bestPathEnd = origin;
            if (bestPathEnd.mask == 0)
                break;
            (graph[origin.index][origin.time] || []).forEach(function (edge) {
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


    function solveTsp(locations, distances, success) {
        function distance(origin, destination) {
            return distances[origin][destination];
        }

        console.log("Locations:");
        console.log(locations);

        var route = findRoute(distance, locations, 10);

        console.log("DJP:") ;
        console.log(JSON.stringify(route));

        success(route);
    }

    return {
        solve: function (locations, success, failure) {
            var points = locations.map(function (value) {
                return value.latLng;
            });
            Distance.distanceMatrix(points, function (distances) {
                solveTsp(locations, distances, success);
            }, failure);
        }
    };

}]);


tspSolver.factory('DPTspSolver', ['Distance', function (Distance) {
    function WayPoint(d, a) {
        this.duration = d;
        this.arrival = a;
    }

    WayPoint.prototype.toString = function() {
        return "[" + this.duration + ", " + this.arrival + "]";
    };

    function findRoute(waypoints, d) {
        "use strict";

        function nextSetWithAtLeast(n) {
            var count = 0;
            var ret = 0;

            var i;
            for (i = 0; i < waypointsN; ++i) {
                count += curSetBitMask[i];
            }

            if (count < n) {
                for (i = 0; i < n; ++i) {
                    curSetBitMask[i] = 1;
                }

                for (i = n; i < waypointsN; ++i) {
                    curSetBitMask[i] = 0;
                }
            } else {
                // Find first `1`
                var firstOne = -1;
                for (i = 0; i < waypointsN; ++i) {
                    if (curSetBitMask[i]) {
                        firstOne = i;
                        break;
                    }
                }

                // Find first 0 greater than firstOne
                var firstZero = -1;
                for (i = firstOne + 1; i < waypointsN; ++i) {
                    if (!curSetBitMask[i]) {
                        firstZero = i;
                        break;
                    }
                }

                if (firstZero < 0) {
                    return -1;
                }

                // Increment the first zero with ones behind it
                curSetBitMask[firstZero] = 1;

                // Set the part behind that one to its lowest possible value
                for (i = 0; i < firstZero - firstOne - 1; ++i) {
                    curSetBitMask[i] = 1;
                }

                for (i = firstZero - firstOne - 1; i < firstZero; ++i) {
                    curSetBitMask[i] = 0;
                }
            }

            // Return the curSet for this set
            for (i = 0; i < waypointsN; ++i) {
                ret += (curSetBitMask[i]<<i);
            }

            return ret;
        }

        var waypointsN = waypoints.length;

        var sentry      = 2000000000; // Approx. 63 years., this long a route should not be reached...
        var bestTrip    = sentry;

        var bestPath = [];
        var curSetBitMask = [];

        var permutationsN = 1 << waypointsN;

        var C = [];
        var P = [];

        var i, k, curSet;

        for (i = 0; i < permutationsN; ++i) {
            C[i] = [];
            P[i] = [];

            for (var j = 0; j < waypointsN; ++j) {
                C[i][j] = new WayPoint(0.0, 0);
                P[i][j] = -1;
            }
        }

        for (k = 1; k < waypointsN; ++k) {
            curSet = 1 + (1 << k);
            C[curSet][k] = new WayPoint(d[0][k], waypoints[k].from);
            P[curSet][k] = 0;
        }

        for (var s = 3; s <= waypointsN; ++s) {
            for (i = 0; i < waypointsN; ++i) {
                curSetBitMask[i] = 0;
            }

            curSet = nextSetWithAtLeast(s);

            while (curSet >= 0) {

                for (k = 1; k < waypointsN; ++k) {
                    if (curSetBitMask[k]) {
                        var prevSet = curSet - (1 << k);

                        C[curSet][k] = new WayPoint(sentry, -1);

                        for (var m = 1; m < waypointsN; ++m) {
                            if (curSetBitMask[m] && m != k) {

                                var arrivalEstimated = C[prevSet][m].arrival + d[m][k] /* + someTime */;
                                var arrivalActual    = arrivalEstimated;

                                // Check whether we've estimated early arrivalActual, therefore TS need to wait
                                if (arrivalEstimated < waypoints[k].from)
                                    arrivalActual = waypoints[k].from;

                                var durationEstimated = C[prevSet][m].duration + (arrivalActual - arrivalEstimated) + d[m][k] /* + someTime */;

                                if (/* arrivalEstimated >= waypoints[k].from && */ arrivalActual <= waypoints[k].to && durationEstimated < C[curSet][k].duration) {
                                    C[curSet][k] = new WayPoint(durationEstimated, arrivalActual);
                                    P[curSet][k] = m;
                                }

                            }
                        }
                    }
                }

                curSet = nextSetWithAtLeast(s);
            }
        }

        // Best-path setup

        bestPath[0] = {
            point:  waypoints[0],
            time:   0
        };

        curSet = (1 << waypointsN) - 1;

        var curNode = -1, prevNode = -1;

        for (i = 1; i < waypointsN; ++i) {
            var duration = C[curSet][i].duration;

            if (duration < bestTrip) {
                bestTrip    = duration;
                curNode     = i;
            }
        }

        if (window.$DEBUG) {
            console.log(bestTrip);
        }


        for (i = waypointsN; i > 0; --i) {

            if (curNode == -1 && i != 1) {
                _dumpFailure(C, P, d);
                throw "Delivr.Route.Composition.Exception";
            }

            var durationUpTo    = C[curSet][curNode].duration;
            var arrivalTo       = C[curSet][curNode].arrival;

            bestPath[i - 1] = {
                point:  waypoints[curNode],
                time:   arrivalTo
            };

            if (window.$DEBUG) {
                console.log("To: " + i + "/" + durationUpTo + "/" + arrivalTo);
            }

            prevNode = curNode;
            curNode = P[curSet][curNode];

            curSet -= (1 << prevNode);
        }

        return bestPath;
    }

    function _dumpMatrix(m) {
        printMatrix(m);

        // TODO: Make an AJAX to dump it
        //var serialized = JSON.stringify(m);
    }

    function _dumpFailure(c, p, d) {
        _dumpMatrix(c);
        _dumpMatrix(p);
        _dumpMatrix(d);
    }

    function printMatrix(m) {
        for (var i = 0; i < m.length; ++i) {
            var row = "";
            for (var j = 0; j < m[i].length; ++j) {
                row += m[i][j] + ", ";
            }
            console.log("#" + i + ": " + row);
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////


    function solveTsp(locations, distances, success) {
        console.log("Locations:");
        console.log(locations);

        var route = findRoute(locations, distances);

        console.log("DynP:") ;
        console.log(JSON.stringify(route));

        success(route);
    }

    return {
        solve: function (locations, success, failure) {
            var points = locations.map(function (value) {
                return value.latLng;
            });
            Distance.distanceMatrix(points, function (distances) {
                solveTsp(locations, distances, success);
            }, failure);
        }
    };

}]);
