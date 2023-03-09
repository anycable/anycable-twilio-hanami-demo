import CableReady from 'cable_ready';
import { createConsumer } from "@anycable/web";

const consumer = createConsumer();

CableReady.initialize({ consumer });
