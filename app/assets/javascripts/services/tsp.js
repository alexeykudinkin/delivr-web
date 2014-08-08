var tspSolver = angular.module('tspSolver', ['environmentServices', 'algorithms']);

tspSolver.factory('TspSolver', ['Distance', 'DataStructures', function (Distance, DataStructures) {
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

        points.forEach(function (value, origin, array) {
            for (var currentTime = roundDown(points[origin].from);
                       currentTime <= points[origin].to; currentTime += timeStep) {

                makeEdge({ index: origin, time: currentTime },
                         { index: origin, time: currentTime + timeStep }, 0);
                
                for (var destination = 0; destination < points.length; ++destination) {
                    if (origin == destination)
                        continue;

                    var duration = distance(origin, destination);
                    var destinationTime = roundUp(currentTime + duration);
                    if (destinationTime > roundUp(points[destination].to) ||
                          destinationTime < roundDown(points[destination].from))
                        continue;

                    makeEdge({ index: origin, time: currentTime },
                             { index: destination, time: destinationTime },
                             duration);
                }
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
            return (origin.time - destination.time) ||
                   (durationTo(origin) - durationTo(destination)) ||
                   compareMasks(origin.mask, destination.mask) ||
                   (origin.index - destination.index);
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
            (graph[origin.index][origin.time] || []).forEach(function (edge, index, array) {
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

         success(findRoute(distance, locations, 10));
    }

    return {
        solve: function (locations, success, failure) {
            var points = locations.map(function (value, index, array) {
                return value.latLng;
            });
            Distance.distanceMatrix(points, function (distances) {
                solveTsp(locations, distances, success);
            }, failure);
        }
    };

}]);
