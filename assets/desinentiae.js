// Highlight every cell that shares an ending with the hovered one.
(function () {
  var CELL_SELECTOR = 'td[data-desinentiae]';
  var MATCH_CLASS = 'desinentia-match';

  function desinentiae(cell) {
    return new Set((cell.dataset.desinentiae || '').split(/\s+/).filter(Boolean));
  }

  function sharesEnding(a, b) {
    for (var ending of a) {
      if (b.has(ending)) return true;
    }
    return false;
  }

  function clear() {
    document.querySelectorAll('.' + MATCH_CLASS).forEach(function (cell) {
      cell.classList.remove(MATCH_CLASS);
    });
  }

  function highlight(target) {
    clear();
    var reference = desinentiae(target);
    if (!reference.size) return;
    document.querySelectorAll(CELL_SELECTOR).forEach(function (cell) {
      if (sharesEnding(reference, desinentiae(cell))) {
        cell.classList.add(MATCH_CLASS);
      }
    });
  }

  document.querySelectorAll(CELL_SELECTOR).forEach(function (cell) {
    cell.addEventListener('mouseenter', function () {
      highlight(cell);
    });
  });

  document.querySelectorAll('table').forEach(function (table) {
    table.addEventListener('mouseleave', clear);
  });
})();
