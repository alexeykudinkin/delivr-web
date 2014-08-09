
    function WayPoint(d, a) {
      this.duration = d;
      this.arrival = a;
    }

    WayPoint.prototype.toString = function() {
      return "[" + this.duration + ", " + this.arrival + "]";
    };

    function dynamicP(waypoints, d) {
        "use strict";

        function nextPermutationOf(n) {
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

        var maxTripSentry = 2000000000; // Approx. 63 years., this long a route should not be reached...
        var bestTrip = maxTripSentry;

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
        }

        for (var s = 3; s <= waypointsN; ++s) {
            for (i = 0; i < waypointsN; ++i) {
                curSetBitMask[i] = 0;
            }

            curSet = nextPermutationOf(s);

            while (curSet >= 0) {

                console.log(curSet);

                for (k = 1; k < waypointsN; ++k) {
                    if (curSetBitMask[k]) {
                        var prevSet = curSet - (1 << k);

                        C[curSet][k] = new WayPoint(maxTripSentry, -1);

                        for (var m = 1; m < waypointsN; ++m) {
                            if (curSetBitMask[m] && m != k) {
                                var arrivalEstimated = C[prevSet][m].arrival + d[m][k] /* + someTime */;
                                var arrivalActual    = arrivalEstimated;

                                // Check whether we've estimated early arrivalActual, therefore TS need to wait
                                if (arrivalEstimated < waypoints[k].from)
                                    arrivalActual = waypoints[k].from;

                                var durationEstimated = C[prevSet][m].duration + (arrivalActual - arrivalEstimated) + d[m][k] /* + someTime */;

                                if (/* arrivalEstimated >= waypoints[k].from && */ arrivalActual <= waypoints[k].to && durationEstimated < C[curSet][k].duration) {
                                    C[curSet][k] = new WayPoint(durationEstimated, arrivalEstimated);
                                    P[curSet][k] = m;
                                }
                            }
                        }
                    }
                }

                curSet = nextPermutationOf(s);
            }
        }

//        for (i = 0; i < waypointsN; ++i) {
//            bestPath[i] = 0;
//        }

        curSet = (1 << waypointsN) - 1;

//        if (mode == 0) {

            var curNode = -1;

            for (i = 1; i < waypointsN; ++i) {
                var duration = C[curSet][i].duration;

                if (duration < bestTrip) {
                    bestTrip    = duration;
                    curNode     = i;
                }
            }

            bestPath[waypointsN - 1] = curNode;

//        } else {

//            var curNode = waypointsN - 1;
//
//            bestPath[curNode] = curNode;
//            bestTrip = C[curSet][curNode];

//        }

        for (i = waypointsN - 1; i > 0; --i) {
            console.log("To: " + i + "/" + C[curSet][curNode].duration + "/" + C[curSet][curNode].arrival);

            curNode = P[curSet][curNode];

            if (curNode == -1 && i != 1) {
                _dumpDebug(C, P); throw "Ooops";
            } else {
                curSet -= (1 << bestPath[i]);
                bestPath[i - 1] = curNode;
            }
        }

        console.log(bestTrip);

        //bestPath[0] = 0;

        return bestPath;
      }

    function _dumpMatrix(m) {
        //printMatrix(m);
        var serialized = JSON.stringify(m);
        // TODO: Make an AJAX to dump it
    }

    function _dumpDebug(c, p) {
        _dumpMatrix(c);
        _dumpMatrix(p);
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

(function testA() {
  var waypoints = [
    { from: 0, to: 24 }, { from: 10, to: 11 }, { from: 11, to: 12 }
  ];

  var distances = [
    [ 0.0,  0.5,  0.5 ],
    [ 0.5,  0.0,  0.5 ],
    [ 0.5,  0.5,  0.0 ],
  ];

  // [ -1, 1, 2 ]
  console.log(dynamicP(waypoints, distances));

}());

(function testB() {
  var waypoints = [
    { from: 0,    to: 24 },
    { from: 10,   to: 11 }, { from: 11, to: 12 },
    { from: 11.5, to: 12 },

  ];

  var distances = [
    [ 0.0,  0.5,  0.5,  1.5 ],
    [ 0.5,  0.0,  0.5,  0.5 ],
    [ 0.5,  0.5,  0.0,  1.0 ],
    [ 1.5,  0.5,  1.0,  0.0 ],
  ];

  // [ -1, 1, 2, 3 ]
  console.log(dynamicP(waypoints, distances));

}());

(function testC() {
  var waypoints = [
    { from: 0,    to: 24 },
    { from: 10,   to: 11 }, { from: 10, to: 12 },
    { from: 11.5, to: 12 },
  ];

  var distances = [
    [ 0.0,  0.5,  0.5,  1.5 ],
    [ 0.5,  0.0,  0.5,  0.5 ],
    [ 0.5,  0.5,  0.0,  1.0 ],
    [ 1.5,  0.5,  1.0,  0.0 ],
  ];

  // [ -1, 2, 1, 3 ]
  console.log(dynamicP(waypoints, distances));

}());



