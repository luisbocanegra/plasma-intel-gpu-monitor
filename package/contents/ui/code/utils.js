/**
 * Parses the output of intel_gpu_top, which is a string containing a stream of
 * multiple JSON objects, we extract the last one as it is the most accurate
 * @param {string} statsString Stats string from intel_gpu_top -J
 * @returns {object} Last good stats object
 */
function getCurrentUsage(statsString) {

  var lines = statsString.split("\n");
  let jsonObject = '';
  let goodObjects = [];

  lines.forEach((line) => {

    if (line.startsWith('{')) {
      jsonObject = line;
    }

    else if (line.startsWith('},')) {
      jsonObject += '}';

      try {
        let parsedObject = JSON.parse(jsonObject);
        goodObjects.push(parsedObject);
      } catch (error) {
        console.error('Broken object:', jsonObject);
      }

      // Reset for the next object
      jsonObject = '';
    }
    // Otherwise, add the line to the current object
    else {
      jsonObject += line;
    }
  });

  return goodObjects[goodObjects.length - 1];
}

/**
 * convert pysical engines to classes (removes /NUMBER at the end) from intel_gpu_top  -J
 * @param {object} stats intel_gpu_top stats object
 * @returns {object} stats with renamed engines
 */
function renameEngines(stats) {
  for (let key in stats.engines) {
    let parts = key.split("/")
    if (!isNaN(Number(parts[parts.length - 1]))) {
      parts.pop()
      let newKey = parts.join("/")

      stats.engines[newKey] = stats.engines[key];
      delete stats.engines[key];
    }
  }
  return stats
}

/**
 * Filter out clients based on 'busy' value of the specified engine class name
 * @param {object} usageNow stats object
 * @param {string} engineClass engine name
 * @returns 
 */
function getSortedClients(usageNow, engineClass) {
  var filteredClients = Object.keys(usageNow.clients).filter(function (clientId) {
    var clientData = usageNow.clients[clientId];
    return engineClass in clientData['engine-classes'] && parseFloat(clientData['engine-classes'][engineClass]['busy']) > 0;
  }).map(function (clientId) {
    // Include client info in the list
    var clientData = usageNow.clients[clientId];
    return {
      id: clientId,
      name: clientData.name,
      pid: clientData.pid,
      engines: clientData['engine-classes']
    };
  });

  // Sort clients by 'busy' value
  var sortedClients = filteredClients.sort(function (a, b) {
    return parseFloat(a.engines[engineClass]['busy']) - parseFloat(b.engines[engineClass]['busy']);
  });

  return sortedClients.slice(0, maxClients);
}
/**
 * Return a color between green and red based on utilization
 * @param {number} load Utilization 0-100
 * @param {number} dimThreshold Idle threshold to return a dimm color
 * @returns {color} Qt color
 */
function getBadeColor(load, dimThreshold) {
  // Map the load to a hue value (subtract from 120 for 0 to be green and 100 to be red)
  load = Math.max(0, Math.min(100, load));
  var hue = 120 - (load * 1.2);
  var lightness = badgeLightness
  var staturation = 1.0
  if (load < dimThreshold) {
    hue = 193
    staturation = .6
    lightness = 0.3
  }
  return Qt.hsla(hue / 360, staturation, lightness, 1)
}

/**
 * Returns properties for the widget icon `{icon:string, busy: number, color: string}`
 * @param {object} usageNow GPU stats
 * @param {number} threshold3d 3D idle threshold
 * @param {number} thresholdVideo Video idle threshold
 * @param {number} thresholdVideoEnhance Video Enhance idle threshold
 * @param {number} thresholdBlitter Blitter idle threshold
 * @returns {object} `{icon:string, busy: number, color: string}`
 */
function getActiveEngineIcon(usageNow, threshold3d, thresholdVideo, thresholdVideoEnhance, thresholdBlitter) {
  var engines = {
    'VideoEnhance': { threshold: thresholdVideoEnhance, icon: "icon-hwe.svg" },
    'Video': { threshold: thresholdVideo, icon: "icon-hw.svg" },
    'Blitter': { threshold: thresholdBlitter, icon: "icon-blitter.svg" },
    'Render/3D': { threshold: threshold3d, icon: "icon-3d.svg" }
  };

  var engineInfo = { icon: "icon-idle.svg", busy: 100 - usageNow.rc6.value, color: idleColor };

  for (var engine in engines) {
    var busyEngine = usageNow.engines[engine];
    if (busyEngine.busy > engines[engine].threshold) {
      engineInfo.icon = engines[engine].icon;
      engineInfo.busy = busyEngine.busy;
      engineInfo.color = getBadeColor(engineInfo.busy, engines[engine].threshold);
      break;
    }
  }
  return engineInfo;
}

/**
 * Fill missing properties of an object with properties of base object
 * @param {object} baseObject Base Object
 * @param {object} newObject New object
 * @returns {object} Merged object
 */
function mergeObjects(baseObject, newObject) {
  for (var key in baseObject) {
    if (typeof baseObject[key] === "object" && baseObject[key] !== null) {
      if (!newObject.hasOwnProperty(key)) {
        newObject[key] = {}
      }
      mergeObjects(baseObject[key], newObject[key])
    } else {
      if (!newObject.hasOwnProperty(key)) {
        newObject[key] = baseObject[key]
      }
    }
  }
  return newObject
}
