(function () {
  'use strict';

  var root = document.querySelector('[data-graph-root]');
  if (!root) return;

  var svg = root.querySelector('[data-graph-svg]');
  var viewport = root.querySelector('[data-graph-viewport]');
  var edgeLayer = root.querySelector('[data-graph-edges]');
  var nodeLayer = root.querySelector('[data-graph-nodes]');
  var searchInput = root.querySelector('[data-graph-search]');
  var directory = root.querySelector('[data-graph-directory]');
  var status = root.querySelector('[data-graph-status]');
  var summary = root.querySelector('[data-graph-summary]');
  var detail = root.querySelector('[data-graph-detail]');
  var emptyDetail = root.querySelector('[data-graph-empty]');
  var detailMeta = root.querySelector('[data-graph-detail-meta]');
  var detailTitle = root.querySelector('[data-graph-detail-title]');
  var detailSummary = root.querySelector('[data-graph-detail-summary]');
  var detailTopics = root.querySelector('[data-graph-detail-topics]');
  var detailLink = root.querySelector('[data-graph-detail-link]');
  var neighborList = root.querySelector('[data-graph-neighbors]');
  var nodeCount = root.querySelector('[data-graph-node-count]');
  var edgeCount = root.querySelector('[data-graph-edge-count]');
  var typeButtons = Array.prototype.slice.call(root.querySelectorAll('[data-graph-type]'));
  var activeTypes = new Set(['paper', 'dataset']);
  var graph = null;
  var byId = new Map();
  var adjacency = new Map();
  var positions = new Map();
  var selectedId = null;
  var query = '';
  var transform = { x: 0, y: 0, scale: 1 };
  var pan = null;
  var SVG_NS = 'http://www.w3.org/2000/svg';

  function svgElement(name, attributes) {
    var element = document.createElementNS(SVG_NS, name);
    Object.keys(attributes || {}).forEach(function (key) {
      element.setAttribute(key, attributes[key]);
    });
    return element;
  }

  function normalizedText(node) {
    return [node.title, node.shortTitle, node.summary, node.meta].concat(node.topics || []).join(' ').toLowerCase();
  }

  function matchesSearch(node) {
    return !query || normalizedText(node).indexOf(query) !== -1;
  }

  function isVisible(node) {
    return activeTypes.has(node.type);
  }

  function shortLabel(value) {
    var limit = 24;
    return value.length > limit ? value.slice(0, limit - 1).trim() + '…' : value;
  }

  function calculateLayout(nodes, edges) {
    var width = 1000;
    var height = 700;
    var padding = 72;
    var count = nodes.length;
    var local = new Map();

    if (count > 150) {
      var columns = Math.ceil(Math.sqrt(count * 1.4));
      var rows = Math.ceil(count / columns);
      nodes.forEach(function (node, index) {
        var column = index % columns;
        var row = Math.floor(index / columns);
        local.set(node.id, {
          x: padding + column * ((width - padding * 2) / Math.max(1, columns - 1)),
          y: padding + row * ((height - padding * 2) / Math.max(1, rows - 1))
        });
      });
      return local;
    }

    nodes.forEach(function (node, index) {
      var angle = index * 2.399963229728653;
      var radius = 70 + Math.sqrt(index + 1) * 68;
      var typeOffset = node.type === 'dataset' ? 65 : -10;
      local.set(node.id, {
        x: width / 2 + Math.cos(angle) * radius + typeOffset,
        y: height / 2 + Math.sin(angle) * radius
      });
    });

    var edgePairs = edges.map(function (edge) {
      return { a: edge.source, b: edge.target, weight: edge.weight || 1 };
    });

    for (var iteration = 0; iteration < 180; iteration += 1) {
      var force = new Map();
      nodes.forEach(function (node) { force.set(node.id, { x: 0, y: 0 }); });

      for (var leftIndex = 0; leftIndex < count; leftIndex += 1) {
        for (var rightIndex = leftIndex + 1; rightIndex < count; rightIndex += 1) {
          var left = local.get(nodes[leftIndex].id);
          var right = local.get(nodes[rightIndex].id);
          var dx = left.x - right.x;
          var dy = left.y - right.y;
          var distanceSquared = Math.max(120, dx * dx + dy * dy);
          var distance = Math.sqrt(distanceSquared);
          var repulsion = 8200 / distanceSquared;
          var fx = dx / distance * repulsion;
          var fy = dy / distance * repulsion;
          force.get(nodes[leftIndex].id).x += fx;
          force.get(nodes[leftIndex].id).y += fy;
          force.get(nodes[rightIndex].id).x -= fx;
          force.get(nodes[rightIndex].id).y -= fy;
        }
      }

      edgePairs.forEach(function (edge) {
        var left = local.get(edge.a);
        var right = local.get(edge.b);
        if (!left || !right) return;
        var dx = right.x - left.x;
        var dy = right.y - left.y;
        var distance = Math.max(1, Math.sqrt(dx * dx + dy * dy));
        var target = 135 + Math.max(0, 4 - edge.weight) * 12;
        var spring = (distance - target) * 0.0009;
        var fx = dx / distance * spring;
        var fy = dy / distance * spring;
        force.get(edge.a).x += fx;
        force.get(edge.a).y += fy;
        force.get(edge.b).x -= fx;
        force.get(edge.b).y -= fy;
      });

      nodes.forEach(function (node) {
        var point = local.get(node.id);
        var movement = force.get(node.id);
        movement.x += (width / 2 - point.x) * 0.00045;
        movement.y += (height / 2 - point.y) * 0.00045;
        point.x = Math.max(padding, Math.min(width - padding, point.x + movement.x * 9));
        point.y = Math.max(padding, Math.min(height - padding, point.y + movement.y * 9));
      });
    }

    return local;
  }

  function buildAdjacency() {
    graph.nodes.forEach(function (node) { adjacency.set(node.id, []); });
    graph.edges.forEach(function (edge) {
      if (!adjacency.has(edge.source) || !adjacency.has(edge.target)) return;
      adjacency.get(edge.source).push({ nodeId: edge.target, edge: edge });
      adjacency.get(edge.target).push({ nodeId: edge.source, edge: edge });
    });
    adjacency.forEach(function (items) {
      items.sort(function (left, right) {
        return (right.edge.weight || 0) - (left.edge.weight || 0) || byId.get(left.nodeId).title.localeCompare(byId.get(right.nodeId).title);
      });
    });
  }

  function renderEdges() {
    edgeLayer.replaceChildren();
    graph.edges.forEach(function (edge) {
      var source = positions.get(edge.source);
      var target = positions.get(edge.target);
      if (!source || !target) return;
      var line = svgElement('line', {
        x1: source.x,
        y1: source.y,
        x2: target.x,
        y2: target.y,
        'class': 'graph-edge',
        'data-source': edge.source,
        'data-target': edge.target,
        'data-edge-id': edge.id
      });
      var title = svgElement('title');
      title.textContent = edge.label;
      line.appendChild(title);
      edgeLayer.appendChild(line);
    });
  }

  function selectNode(id, announce) {
    var node = byId.get(id);
    if (!node) return;
    selectedId = id;
    emptyDetail.hidden = true;
    detail.hidden = false;
    detailMeta.textContent = (node.type === 'paper' ? 'Paper Bite' : 'Data Bite') + (node.meta ? ' / ' + node.meta : '');
    detailTitle.textContent = node.title;
    detailSummary.textContent = node.summary;
    detailLink.href = node.url;
    detailTopics.replaceChildren();
    node.topics.forEach(function (topic) {
      var chip = document.createElement('span');
      chip.textContent = topic;
      detailTopics.appendChild(chip);
    });

    neighborList.replaceChildren();
    var neighbors = (adjacency.get(id) || []).filter(function (item) {
      return isVisible(byId.get(item.nodeId));
    });
    neighbors.forEach(function (item) {
      var neighbor = byId.get(item.nodeId);
      var listItem = document.createElement('li');
      var button = document.createElement('button');
      button.type = 'button';
      button.className = 'graph-neighbor-button';
      button.dataset.selectNode = neighbor.id;
      var title = document.createElement('span');
      title.className = 'graph-neighbor-title';
      title.textContent = neighbor.shortTitle;
      var relation = document.createElement('span');
      relation.className = 'graph-neighbor-relation';
      relation.textContent = item.edge.label;
      button.appendChild(title);
      button.appendChild(relation);
      listItem.appendChild(button);
      neighborList.appendChild(listItem);
    });
    if (!neighbors.length) {
      var listItem = document.createElement('li');
      listItem.className = 'graph-neighbor-relation';
      listItem.textContent = 'No visible direct connections';
      neighborList.appendChild(listItem);
    }

    updateVisualState();
    if (announce !== false) status.textContent = 'Selected ' + node.shortTitle + ' / ' + neighbors.length + ' direct connections';
  }

  function clearSelection() {
    selectedId = null;
    detail.hidden = true;
    emptyDetail.hidden = false;
    updateVisualState();
  }

  function renderNodes() {
    nodeLayer.replaceChildren();
    graph.nodes.forEach(function (node) {
      var point = positions.get(node.id);
      var group = svgElement('g', {
        'class': 'graph-node',
        'data-node-id': node.id,
        'data-type': node.type,
        role: 'button',
        tabindex: '0',
        'aria-label': 'Select ' + node.title + ', ' + (node.type === 'paper' ? 'Paper Bite' : 'Data Bite')
      });
      group.setAttribute('transform', 'translate(' + point.x.toFixed(2) + ' ' + point.y.toFixed(2) + ')');

      var shape;
      if (node.type === 'dataset') {
        shape = svgElement('rect', { x: -12, y: -12, width: 24, height: 24, transform: 'rotate(45)', 'class': 'graph-node-shape' });
      } else {
        shape = svgElement('circle', { r: 13, 'class': 'graph-node-shape' });
      }
      var label = svgElement('text', { x: 20, y: 2, 'class': 'graph-node-label' });
      label.textContent = shortLabel(node.shortTitle);
      var type = svgElement('text', { x: 20, y: 15, 'class': 'graph-node-type' });
      type.textContent = node.type === 'paper' ? 'Paper' : 'Data';
      var title = svgElement('title');
      title.textContent = node.title;
      group.appendChild(shape);
      group.appendChild(label);
      group.appendChild(type);
      group.appendChild(title);
      group.addEventListener('click', function () { selectNode(node.id); });
      group.addEventListener('keydown', function (event) {
        if (event.key === 'Enter' || event.key === ' ') {
          event.preventDefault();
          selectNode(node.id);
        }
      });
      nodeLayer.appendChild(group);
    });
  }

  function renderDirectory() {
    directory.replaceChildren();
    graph.nodes.slice().sort(function (left, right) {
      return left.type.localeCompare(right.type) || left.title.localeCompare(right.title);
    }).forEach(function (node) {
      var link = document.createElement('a');
      link.className = 'graph-directory-item';
      link.href = node.url;
      link.dataset.directoryId = node.id;
      var meta = document.createElement('div');
      meta.className = 'graph-directory-meta';
      var type = document.createElement('span');
      type.textContent = node.type === 'paper' ? 'Paper Bite' : 'Data Bite';
      var detail = document.createElement('span');
      detail.textContent = node.meta || '';
      meta.appendChild(type);
      meta.appendChild(detail);
      var title = document.createElement('h3');
      title.textContent = node.title;
      var topics = document.createElement('p');
      topics.className = 'graph-directory-topics';
      topics.textContent = node.topics.slice(0, 4).join(' / ');
      link.appendChild(meta);
      link.appendChild(title);
      link.appendChild(topics);
      directory.appendChild(link);
    });
  }

  function updateVisualState() {
    var selectedNeighbors = new Set();
    if (selectedId) {
      selectedNeighbors.add(selectedId);
      (adjacency.get(selectedId) || []).forEach(function (item) { selectedNeighbors.add(item.nodeId); });
    }

    Array.prototype.forEach.call(nodeLayer.querySelectorAll('.graph-node'), function (element) {
      var node = byId.get(element.dataset.nodeId);
      var visible = isVisible(node);
      var searchMatch = matchesSearch(node);
      var related = !selectedId || selectedNeighbors.has(node.id);
      if (visible) element.removeAttribute('hidden'); else element.setAttribute('hidden', '');
      element.classList.toggle('is-selected', node.id === selectedId);
      element.classList.toggle('is-search-match', Boolean(query) && searchMatch);
      element.classList.toggle('is-dim', visible && ((!searchMatch && Boolean(query)) || !related));
      element.setAttribute('aria-hidden', String(!visible));
      element.setAttribute('tabindex', visible ? '0' : '-1');
    });

    Array.prototype.forEach.call(edgeLayer.querySelectorAll('.graph-edge'), function (element) {
      var source = byId.get(element.dataset.source);
      var target = byId.get(element.dataset.target);
      var visible = isVisible(source) && isVisible(target);
      var related = selectedId && (source.id === selectedId || target.id === selectedId);
      var searchRelated = !query || matchesSearch(source) || matchesSearch(target);
      if (visible) element.removeAttribute('hidden'); else element.setAttribute('hidden', '');
      element.classList.toggle('is-related', Boolean(related));
      element.classList.toggle('is-dim', visible && ((selectedId && !related) || !searchRelated));
    });

    var visibleCount = 0;
    Array.prototype.forEach.call(directory.querySelectorAll('[data-directory-id]'), function (element) {
      var node = byId.get(element.dataset.directoryId);
      var show = isVisible(node) && matchesSearch(node);
      element.hidden = !show;
      if (show) visibleCount += 1;
    });

    var visibleEdges = graph.edges.filter(function (edge) {
      return isVisible(byId.get(edge.source)) && isVisible(byId.get(edge.target));
    }).length;
    summary.textContent = visibleCount + ' entries / ' + visibleEdges + ' relationships';
    if (!selectedId) status.textContent = visibleCount + ' visible entries / select a node';
  }

  function applyTransform() {
    viewport.setAttribute('transform', 'translate(' + transform.x.toFixed(2) + ' ' + transform.y.toFixed(2) + ') scale(' + transform.scale.toFixed(3) + ')');
  }

  function resetView() {
    transform = { x: 0, y: 0, scale: 1 };
    applyTransform();
  }

  function zoomBy(factor) {
    var next = Math.max(0.55, Math.min(2.8, transform.scale * factor));
    var centerX = 500;
    var centerY = 350;
    var ratio = next / transform.scale;
    transform.x = centerX - (centerX - transform.x) * ratio;
    transform.y = centerY - (centerY - transform.y) * ratio;
    transform.scale = next;
    applyTransform();
  }

  function resetAll() {
    activeTypes = new Set(['paper', 'dataset']);
    typeButtons.forEach(function (button) {
      button.classList.add('is-active');
      button.setAttribute('aria-pressed', 'true');
    });
    query = '';
    searchInput.value = '';
    clearSelection();
    resetView();
    updateVisualState();
    status.textContent = graph.nodes.length + ' visible entries / graph reset';
  }

  function attachControls() {
    searchInput.addEventListener('input', function () {
      query = searchInput.value.trim().toLowerCase();
      updateVisualState();
    });

    typeButtons.forEach(function (button) {
      button.addEventListener('click', function () {
        var type = button.dataset.graphType;
        if (activeTypes.has(type) && activeTypes.size === 1) return;
        if (activeTypes.has(type)) activeTypes.delete(type); else activeTypes.add(type);
        var active = activeTypes.has(type);
        button.classList.toggle('is-active', active);
        button.setAttribute('aria-pressed', String(active));
        if (selectedId && !activeTypes.has(byId.get(selectedId).type)) clearSelection();
        updateVisualState();
      });
    });

    root.querySelector('[data-graph-reset]').addEventListener('click', resetAll);
    root.querySelector('[data-graph-zoom-in]').addEventListener('click', function () { zoomBy(1.2); });
    root.querySelector('[data-graph-zoom-out]').addEventListener('click', function () { zoomBy(1 / 1.2); });

    neighborList.addEventListener('click', function (event) {
      var button = event.target.closest('[data-select-node]');
      if (button) selectNode(button.dataset.selectNode);
    });

    svg.addEventListener('wheel', function (event) {
      event.preventDefault();
      var rect = svg.getBoundingClientRect();
      var pointX = (event.clientX - rect.left) * 1000 / rect.width;
      var pointY = (event.clientY - rect.top) * 700 / rect.height;
      var next = Math.max(0.55, Math.min(2.8, transform.scale * (event.deltaY < 0 ? 1.1 : 0.9)));
      var ratio = next / transform.scale;
      transform.x = pointX - (pointX - transform.x) * ratio;
      transform.y = pointY - (pointY - transform.y) * ratio;
      transform.scale = next;
      applyTransform();
    }, { passive: false });

    svg.addEventListener('pointerdown', function (event) {
      if (event.target.closest && event.target.closest('.graph-node')) return;
      pan = { pointerId: event.pointerId, x: event.clientX, y: event.clientY, originX: transform.x, originY: transform.y };
      svg.setPointerCapture(event.pointerId);
      svg.classList.add('is-panning');
    });
    svg.addEventListener('pointermove', function (event) {
      if (!pan || event.pointerId !== pan.pointerId) return;
      var rect = svg.getBoundingClientRect();
      transform.x = pan.originX + (event.clientX - pan.x) * 1000 / rect.width;
      transform.y = pan.originY + (event.clientY - pan.y) * 700 / rect.height;
      applyTransform();
    });
    function endPan(event) {
      if (!pan || event.pointerId !== pan.pointerId) return;
      pan = null;
      svg.classList.remove('is-panning');
    }
    svg.addEventListener('pointerup', endPan);
    svg.addEventListener('pointercancel', endPan);
  }

  function initialize(data) {
    if (!data || !Array.isArray(data.nodes) || !Array.isArray(data.edges)) throw new Error('Invalid graph data');
    graph = data;
    data.nodes.forEach(function (node) { byId.set(node.id, node); });
    buildAdjacency();
    positions = calculateLayout(data.nodes, data.edges);
    renderEdges();
    renderNodes();
    renderDirectory();
    nodeCount.textContent = String(data.stats ? data.stats.nodes : data.nodes.length).padStart(2, '0');
    edgeCount.textContent = String(data.stats ? data.stats.edges : data.edges.length).padStart(2, '0');
    attachControls();
    updateVisualState();
  }

  fetch(root.dataset.source, { credentials: 'same-origin' })
    .then(function (response) {
      if (!response.ok) throw new Error('Graph data unavailable');
      return response.json();
    })
    .then(initialize)
    .catch(function (error) {
      status.textContent = 'Knowledge graph unavailable';
      summary.textContent = 'Graph unavailable';
      var message = document.createElement('p');
      message.className = 'graph-error';
      message.textContent = 'The knowledge graph could not be loaded. Browse Paper Bites or Data Bites instead.';
      nodeLayer.parentNode.appendChild(message);
      console.error(error);
    });
})();
