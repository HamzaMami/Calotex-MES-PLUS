import * as rolesRepository from "../repositories/roles.repository";
import { Role, Permission } from "../../permissions/interfaces/permissions.interface";

export const getAllRoles = async (): Promise<Role[]> => {
  return rolesRepository.findAll();
};

export const getRoleById = async (id: number): Promise<Role | null> => {
  return rolesRepository.findById(id);
};

export const getRoleWithPermissions = async (
  id: number
): Promise<{ role: Role; permissions: Permission[] } | null> => {
  const role = await rolesRepository.findById(id);
  if (!role) return null;
  const permissions = await rolesRepository.getRolePermissions(id);
  return { role, permissions };
};

export const createRole = async (
  name: string,
  description: string | null
): Promise<Role> => {
  const existing = await rolesRepository.findByName(name);
  if (existing) {
    throw new Error("A role with this name already exists");
  }
  return rolesRepository.create(name, description);
};

export const updateRole = async (
  id: number,
  fields: { name?: string; description?: string }
): Promise<Role> => {
  const role = await rolesRepository.findById(id);
  if (!role) throw new Error("Role not found");
  const updated = await rolesRepository.update(id, fields);
  return updated!;
};

export const deleteRole = async (id: number): Promise<void> => {
  const role = await rolesRepository.findById(id);
  if (!role) throw new Error("Role not found");
  if (role.is_system) throw new Error("System roles cannot be deleted");
  const ok = await rolesRepository.remove(id);
  if (!ok) throw new Error("Role not found");
};

export const setRolePermissions = async (
  id: number,
  permissionIds: number[]
): Promise<void> => {
  const role = await rolesRepository.findById(id);
  if (!role) throw new Error("Role not found");
  if (role.is_system) {
    throw new Error("System roles (e.g. admin) have fixed permissions");
  }
  await rolesRepository.setRolePermissions(id, permissionIds);
};
