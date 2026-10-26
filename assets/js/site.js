// LiteBites interactive features: an extra layer on top of the static page.
// Every feature looks for its markup and does nothing when absent, so pages
// work without JavaScript. Markup lives in _includes/ (see _includes/AGENTS.md).
(function () {
  'use strict';

  function ready(callback) {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', callback);
    } else {
      callback();
    }
  }

  function escapeHtml(value) {
    return String(value == null ? '' : value).replace(/[&<>"']/g, function (character) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[character];
    });
  }

  // ---- Search dialog (_includes/search.html, /search.json) ----------------
  function initSearch() {
    var dialog = document.querySelector('[data-search-dialog]');
    var openers = Array.prototype.slice.call(document.querySelectorAll('[data-search-open]'));
    if (!dialog || typeof dialog.showModal !== 'function') return;

    var input = dialog.querySelector('[data-search-input]');
    var results = dialog.querySelector('[data-search-results]');
    var status = dialog.querySelector('[data-search-status]');
    var index = null;
    var loading = null;
    var active = -1;

    openers.forEach(function (button) {
      button.hidden = false;
      button.addEventListener('click', open);
    });

    function load() {
      if (!loading) {
        loading = fetch(dialog.getAttribute('data-source') || '/search.json')
          .then(function (response) {
            if (!response.ok) throw new Error('Search index unavailable');
            return response.json();
          })
          .then(function (entries) {
            index = entries.map(function (entry) {
              entry.haystack = [entry.title, entry.short, entry.summary, entry.meta, entry.type]
                .concat(entry.tags || []).join(' ').toLowerCase();
              return entry;
            });
          })
          .catch(function () {
            status.textContent = 'Search is unavailable right now.';
          });
      }
      return loading;
    }

    function open() {
      dialog.showModal();
      input.focus();
      input.select();
      load().then(render);
    }

    function score(entry, terms) {
      var total = 0;
      for (var i = 0; i < terms.length; i += 1) {
        var term = terms[i];
        if (entry.haystack.indexOf(term) === -1) return 0;
        if (entry.short.toLowerCase().indexOf(term) !== -1) total += 5;
        if (entry.title.toLowerCase().indexOf(term) !== -1) total += 3;
        if ((entry.tags || []).join(' ').toLowerCase().indexOf(term) !== -1) total += 2;
        total += 1;
      }
      return total;
    }

    function render() {
      if (!index) return;
      var query = input.value.trim().toLowerCase();
      var terms = query.split(/\s+/).filter(Boolean);
      var matches = terms.length
        ? index.map(function (entry) { return { entry: entry, score: score(entry, terms) }; })
            .filter(function (item) { return item.score > 0; })
            .sort(function (a, b) { return b.score - a.score; })
            .map(function (item) { return item.entry; })
        : index.slice(0, 8);
      matches = matches.slice(0, 12);
      active = matches.length ? 0 : -1;
      status.textContent = terms.length
        ? matches.length + (matches.length === 1 ? ' result' : ' results')
        : 'Latest Bites. Type to search ' + index.length + ' entries.';
      results.innerHTML = matches.map(function (entry, position) {
        return '<li><a class="search-result" href="' + escapeHtml(entry.url) + '" data-position="' + position + '">' +
          '<span class="search-result-meta">' + escapeHtml(entry.type) + (entry.date ? ' / ' + escapeHtml(entry.date) : '') + '</span>' +
          '<span class="search-result-title">' + escapeHtml(entry.short) + '</span>' +
          '<span class="search-result-summary">' + escapeHtml(entry.summary) + '</span></a></li>';
      }).join('');
      highlight();
    }

    function highlight() {
      Array.prototype.forEach.call(results.querySelectorAll('.search-result'), function (link, position) {
        link.classList.toggle('is-active', position === active);
        if (position === active) link.scrollIntoView({ block: 'nearest' });
      });
    }

    input.addEventListener('input', render);
    input.addEventListener('keydown', function (event) {
      var links = results.querySelectorAll('.search-result');
      if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
        event.preventDefault();
        if (!links.length) return;
        active = (active + (event.key === 'ArrowDown' ? 1 : -1) + links.length) % links.length;
        highlight();
      } else if (event.key === 'Enter' && links[active]) {
        event.preventDefault();
        window.location.href = links[active].href;
      }
    });
    dialog.addEventListener('click', function (event) {
      if (event.target === dialog) dialog.close();
    });

    document.addEventListener('keydown', function (event) {
      var target = event.target;
      var typing = target && (target.isContentEditable || /^(INPUT|TEXTAREA|SELECT)$/.test(target.tagName));
      if ((event.key === 'k' && (event.metaKey || event.ctrlKey)) || (event.key === '/' && !typing)) {
        event.preventDefault();
        if (!dialog.open) open();
      }
    });
  }

  // ---- Topic chips on archive lists (_includes/topic-filter.html) ----------
  function initTopicFilters() {
    Array.prototype.forEach.call(document.querySelectorAll('[data-topic-filter]'), function (filter) {
      var list = document.querySelector(filter.getAttribute('data-target'));
      if (!list) return;
      var items = Array.prototype.slice.call(list.querySelectorAll('[data-topic-item]'));
      var chips = filter.querySelector('[data-topic-chips]');
      var status = filter.querySelector('[data-topic-status]');
      var counts = {};

      items.forEach(function (item) {
        item.topics = (item.getAttribute('data-topics') || '').split('|').filter(Boolean);
        item.topics.forEach(function (topic) { counts[topic] = (counts[topic] || 0) + 1; });
      });
      var topics = Object.keys(counts).sort(function (a, b) {
        return counts[b] - counts[a] || a.localeCompare(b);
      });
      if (!topics.length) return;

      var VISIBLE = 12;
      var selected = null;
      var expanded = false;

      function chip(label, value, count) {
        var button = document.createElement('button');
        button.type = 'button';
        button.className = 'topic-chip';
        button.setAttribute('data-topic', value);
        button.setAttribute('aria-pressed', String(selected === value));
        button.innerHTML = escapeHtml(label) + (count ? ' <span>' + count + '</span>' : '');
        return button;
      }

      function draw() {
        chips.innerHTML = '';
        chips.appendChild(chip('All', '', items.length));
        topics.forEach(function (topic, position) {
          if (!expanded && position >= VISIBLE && topic !== selected) return;
          chips.appendChild(chip(topic, topic, counts[topic]));
        });
        if (topics.length > VISIBLE) {
          var more = document.createElement('button');
          more.type = 'button';
          more.className = 'topic-chip topic-chip-more';
          more.setAttribute('data-more', '');
          more.textContent = expanded ? 'Fewer topics' : 'All ' + topics.length + ' topics';
          chips.appendChild(more);
        }
      }

      function apply(topic, updateHash) {
        selected = topic || null;
        var shown = 0;
        items.forEach(function (item) {
          var visible = !selected || item.topics.indexOf(selected) !== -1;
          item.hidden = !visible;
          if (visible) shown += 1;
        });
        status.textContent = selected ? shown + ' of ' + items.length + ' tagged “' + selected + '”' : '';
        draw();
        if (updateHash) {
          var hash = selected ? '#topic=' + encodeURIComponent(selected) : ' ';
          history.replaceState(null, '', hash === ' ' ? window.location.pathname : hash);
        }
      }

      chips.addEventListener('click', function (event) {
        var button = event.target.closest('button');
        if (!button) return;
        if (button.hasAttribute('data-more')) {
          expanded = !expanded;
          draw();
          return;
        }
        var topic = button.getAttribute('data-topic');
        apply(topic === selected ? '' : topic, true);
      });

      var match = window.location.hash.match(/^#topic=(.+)$/);
      apply(match && counts[decodeURIComponent(match[1])] ? decodeURIComponent(match[1]) : '', false);
      filter.hidden = false;
    });
  }

  // ---- Sortable benchmark tables (_includes/benchmarks.html) --------------
  function numeric(cell) {
    var value = parseFloat(String(cell.getAttribute('data-value') || cell.textContent).replace(/[^0-9.eE+\-]/g, ''));
    return isNaN(value) ? null : value;
  }

  function initBenchmarks() {
    Array.prototype.forEach.call(document.querySelectorAll('[data-benchmark]'), function (table) {
      var body = table.tBodies[0];
      var headers = Array.prototype.slice.call(table.tHead.rows[0].cells);
      var original = Array.prototype.slice.call(body.rows);

      // Mark the best value in each column that declares a direction.
      headers.forEach(function (header, column) {
        var better = header.getAttribute('data-better');
        if (!better) return;
        var best = null;
        original.forEach(function (row) {
          var value = numeric(row.cells[column]);
          if (value === null) return;
          if (best === null || (better === 'higher' ? value > best : value < best)) best = value;
        });
        original.forEach(function (row) {
          if (numeric(row.cells[column]) === best) row.cells[column].classList.add('is-best');
        });
      });

      headers.forEach(function (header, column) {
        var button = header.querySelector('[data-sort-column]');
        if (!button) return;
        button.addEventListener('click', function () {
          var current = header.getAttribute('aria-sort');
          var next = current === 'none' ? (column === 0 ? 'ascending' : 'descending') : current === 'descending' ? 'ascending' : 'none';
          headers.forEach(function (other) { if (other.hasAttribute('aria-sort')) other.setAttribute('aria-sort', 'none'); });
          header.setAttribute('aria-sort', next);
          var rows = original.slice();
          if (next !== 'none') {
            rows.sort(function (a, b) {
              var left = column === 0 ? a.cells[0].textContent : numeric(a.cells[column]);
              var right = column === 0 ? b.cells[0].textContent : numeric(b.cells[column]);
              var order;
              if (left === null) return 1;
              if (right === null) return -1;
              order = typeof left === 'string' ? left.localeCompare(right) : left - right;
              return next === 'ascending' ? order : -order;
            });
          }
          rows.forEach(function (row) { body.appendChild(row); });
        });
      });
    });
  }

  // ---- Evidence-layer toggle (_includes/claim.html, claim-toggle.html) -----
  function initClaimToggle() {
    var toggle = document.querySelector('[data-claim-toggle]');
    if (!toggle) return;
    var button = toggle.querySelector('button');
    var root = toggle.closest('article') || document.body;
    var key = 'litebites-claims';
    var on = false;
    try { on = localStorage.getItem(key) === 'on'; } catch (error) {}

    function apply() {
      root.classList.toggle('claims-visible', on);
      button.setAttribute('aria-pressed', String(on));
      button.textContent = on ? 'Hide evidence layers' : 'Show evidence layers';
    }

    button.addEventListener('click', function () {
      on = !on;
      try { localStorage.setItem(key, on ? 'on' : 'off'); } catch (error) {}
      apply();
    });
    toggle.hidden = false;
    apply();
  }

  ready(function () {
    initSearch();
    initTopicFilters();
    initBenchmarks();
    initClaimToggle();
  });
})();
