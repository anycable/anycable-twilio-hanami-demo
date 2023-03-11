import CableReady from 'cable_ready';
import { Utils } from 'cable_ready';
import { createConsumer } from "@anycable/web";

// Add append_or_replace operation
CableReady.operations.append_or_replace = operation => {
  const element = document.querySelector(operation.selector);
  if (!element) return;

  const { html, target } = operation;
  const existing = element.querySelector(target);

  if (existing) {
    existing.outerHTML = Utils.safeScalar(html);
  } else {
    element.insertAdjacentHTML('beforeend', Utils.safeScalar(html));
  }
};

const consumer = createConsumer();
CableReady.initialize({ consumer });
