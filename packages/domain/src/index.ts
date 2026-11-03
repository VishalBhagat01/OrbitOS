export { approvalStates, workflowStates } from "@orbit/contracts";
export type { ApprovalState, WorkflowState } from "@orbit/contracts";

export interface TenantContext {
  tenantId: string;
  companyId?: string;
}
