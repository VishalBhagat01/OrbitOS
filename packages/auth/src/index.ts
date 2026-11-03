export interface AuthenticatedPrincipal {
  subject: string;
  tenantId: string;
  companyId?: string;
  permissions: readonly string[];
}

export interface Authorizer {
  can(principal: AuthenticatedPrincipal, permission: string): boolean;
}
