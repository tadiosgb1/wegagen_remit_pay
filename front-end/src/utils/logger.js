// src/utils/logger.js
const isLoggingEnabled = import.meta.env.VITE_APP_LOGGING === 'true'; // General logging flag

const logStyles = {
  info: 'color: blue; font-weight: bold;',
  warn: 'color: orange; font-weight: bold;',
  error: 'color: red; font-weight: bold;',
};

export const Logger = {
  /**
   * Logs an info message
   * @param {string} message - The message to log
   * @param {boolean} [force=false] - If true, logs the message regardless of `isLoggingEnabled`
   */
  info(message, force = false, ...optionalParams) {
    if (isLoggingEnabled || force) {
      console.log(`%cINFO: ${message}`, logStyles.info, ...optionalParams);
    }
  },

  /**
   * Logs a warning message
   * @param {string} message - The message to log
   * @param {boolean} [force=false] - If true, logs the message regardless of `isLoggingEnabled`
   */
  warn(message, force = false, ...optionalParams) {
    if (isLoggingEnabled || force) {
      console.warn(`%cWARN: ${message}`, logStyles.warn, ...optionalParams);
    }
  },

  /**
   * Logs an error message
   * @param {string} message - The message to log
   * @param {boolean} [force=false] - If true, logs the message regardless of `isLoggingEnabled`
   */
  error(message, force = false, ...optionalParams) {
    if (isLoggingEnabled || force) {
      console.error(`%cERROR: ${message}`, logStyles.error, ...optionalParams);
    }
  },
};
