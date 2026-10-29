const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const { test } = require('node:test');
const { runInNewContext } = require('node:vm');

test('macron variants count once per cell and produce one tooltip entry', () => {
  const cells = ['ēī eī ei', 'ei', 'eī', 'ēī', 'e'].map((endings) => {
    const classes = new Set();
    return {
      dataset: { desinentiae: endings },
      classes,
      classList: {
        add: (name) => classes.add(name),
        remove: (name) => classes.delete(name),
      },
      handlers: {},
      addEventListener(name, handler) { this.handlers[name] = handler; },
    };
  });
  const tip = { style: {} };
  const document = {
    querySelectorAll(selector) {
      if (selector === 'td[data-desinentiae]') return cells;
      if (selector === '.desinentia-match') {
        return cells.filter((cell) => cell.classes.has('desinentia-match'));
      }
      return [];
    },
    createElement: () => tip,
    body: { appendChild() {} },
  };
  const script = readFileSync(join(__dirname, '../assets/desinentiae.js'), 'utf8');
  runInNewContext(script, { document });

  for (const cell of cells.slice(0, 4)) {
    cell.handlers.mouseenter({ pageX: 0, pageY: 0 });
    assert.equal(tip.textContent, '-ei: 4x');
    assert.deepEqual(
      cells.map((candidate) => candidate.classes.has('desinentia-match')),
      [true, true, true, true, false],
    );
  }
  cells[4].handlers.mouseenter({ pageX: 0, pageY: 0 });
  assert.equal(tip.textContent, '-e: 1x');
  assert.deepEqual(
    cells.map((cell) => cell.classes.has('desinentia-match')),
    [false, false, false, false, true],
  );
});
