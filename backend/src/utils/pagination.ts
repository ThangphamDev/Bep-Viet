import { Request } from 'express';

export interface PaginationOptions {
  page: number;
  limit: number;
  offset: number;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
    hasNext: boolean;
    hasPrev: boolean;
  };
}

export const getPaginationOptions = (req: Request): PaginationOptions => {
  const page = Math.max(1, parseInt(req.query['page'] as string) || 1);
  const limit = Math.min(100, Math.max(1, parseInt(req.query['limit'] as string) || 20));
  const offset = (page - 1) * limit;

  return { page, limit, offset };
};

export const createPaginatedResponse = <T>(
  data: T[],
  total: number,
  options: PaginationOptions
): PaginatedResponse<T> => {
  const totalPages = Math.ceil(total / options.limit);
  
  return {
    data,
    pagination: {
      page: options.page,
      limit: options.limit,
      total,
      totalPages,
      hasNext: options.page < totalPages,
      hasPrev: options.page > 1,
    },
  };
};

export const sanitizeSearchTerm = (term: string): string => {
  return term
    .trim()
    .replace(/[%_\\]/g, '\\$&') // Escape SQL wildcards
    .substring(0, 255); // Limit length
};

export const buildSearchQuery = (fields: string[], searchTerm: string): string => {
  if (!searchTerm) return '';
  
  const _sanitizedTerm = sanitizeSearchTerm(searchTerm);
  const conditions = fields.map(field => `${field} LIKE ?`).join(' OR ');
  
  return `(${conditions})`;
};

export const getSearchParams = (fields: string[], searchTerm: string): string[] => {
  if (!searchTerm) return [];
  
  const sanitizedTerm = `%${sanitizeSearchTerm(searchTerm)}%`;
  return fields.map(() => sanitizedTerm);
};
