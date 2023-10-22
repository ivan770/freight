import wasm from './glue.js';

export function getMemory() {
    return wasm.memory;
}
