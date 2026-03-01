
/**
 * Error classifications for better UI feedback
 */
export enum SyncErrorType {
  TIMEOUT = 'TIMEOUT',
  NETWORK = 'NETWORK',
  SCHEMA = 'SCHEMA_MISMATCH',
  UNKNOWN = 'UNKNOWN'
}

export class SyncError extends Error {
  constructor(public type: SyncErrorType, message: string, public originalError?: any) {
    super(message);
    this.name = 'SyncError';
  }
}

/**
 * Wraps a promise with a timeout. 
 */
export async function withTimeout<T>(
  promise: Promise<T>, 
  timeoutMs: number = 15000, 
  errorMessage: string = "Request timed out. Please try again."
): Promise<T> {
  let timeoutId: number;
  
  const timeoutPromise = new Promise<T>((_, reject) => {
    timeoutId = window.setTimeout(() => {
      reject(new SyncError(SyncErrorType.TIMEOUT, errorMessage));
    }, timeoutMs);
  });

  return Promise.race([
    promise,
    timeoutPromise
  ]).finally(() => {
    if (timeoutId) clearTimeout(timeoutId);
  });
}

/**
 * Retries a function with exponential backoff.
 * Categorizes errors for specific UI handling.
 */
export async function withRetry<T>(
  fn: () => Promise<T>,
  retries: number = 2,
  baseDelay: number = 1000
): Promise<T> {
  let lastError: any;

  for (let i = 0; i <= retries; i++) {
    try {
      // 10 second internal timeout for each attempt
      return await withTimeout(fn(), 10000);
    } catch (err: any) {
      lastError = err;
      
      // Categorize Error
      const errorMessage = err.message || String(err);
      const isSchemaError = errorMessage.includes('column') || 
                            errorMessage.includes('PGRST204') || 
                            errorMessage.includes('42703') || 
                            errorMessage.includes('42P01');

      if (isSchemaError) {
        throw new SyncError(SyncErrorType.SCHEMA, "Database schema missing fields. Run migration.", err);
      }

      // If it's the last retry, throw the error
      if (i === retries) break;

      // Exponential backoff
      const delay = baseDelay * Math.pow(2, i);
      console.warn(`[Sync] Attempt ${i + 1} failed. Retrying in ${delay}ms...`, err);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }

  throw new SyncError(SyncErrorType.NETWORK, "Network latency detected. Sync delayed.", lastError);
}
