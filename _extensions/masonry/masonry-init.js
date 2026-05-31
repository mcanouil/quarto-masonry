/*!
 * masonry-init.js
 * Auto-initialises Masonry.js on every element carrying a data-masonry attribute.
 * Defers layout until images have loaded when data-masonry-wait-for-images is set,
 * with an optional data-masonry-wait-for-images-timeout (ms) fallback that triggers
 * the layout if imagesLoaded never fires.
 * MIT License
 * by Mickaël Canouil
 */

(function () {
  "use strict";

  function readTimeout(element) {
    var raw = element.getAttribute("data-masonry-wait-for-images-timeout");
    if (raw === null) {
      return null;
    }
    var n = Number(raw);
    if (!isFinite(n) || n < 0) {
      return null;
    }
    return n;
  }

  function initialiseGrid(element) {
    var waitForImages = element.getAttribute("data-masonry-wait-for-images") === "true";
    if (waitForImages && typeof window.imagesLoaded === "function") {
      var laidOut = false;
      var runLayout = function () {
        if (laidOut) {
          return;
        }
        laidOut = true;
        new Masonry(element);
      };
      var timeoutMs = readTimeout(element);
      var timer = null;
      if (timeoutMs !== null) {
        timer = window.setTimeout(runLayout, timeoutMs);
      }
      window.imagesLoaded(element, function () {
        if (timer !== null) {
          window.clearTimeout(timer);
        }
        runLayout();
      });
    } else {
      new Masonry(element);
    }
  }

  function initialiseAll() {
    if (typeof Masonry !== "function") {
      return;
    }
    var grids = document.querySelectorAll("[data-masonry]");
    for (var i = 0; i < grids.length; i++) {
      initialiseGrid(grids[i]);
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initialiseAll);
  } else {
    initialiseAll();
  }
})();
