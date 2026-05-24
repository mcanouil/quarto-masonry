/*!
 * masonry-init.js
 * Auto-initialises Masonry.js on every element carrying a data-masonry attribute.
 * Defers layout until images have loaded when data-masonry-wait-for-images is set.
 * MIT License
 * by Mickaël Canouil
 */

(function () {
  "use strict";

  function initialiseGrid(element) {
    var waitForImages = element.getAttribute("data-masonry-wait-for-images") === "true";
    if (waitForImages && typeof window.imagesLoaded === "function") {
      window.imagesLoaded(element, function () {
        new Masonry(element);
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
