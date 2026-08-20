import * as permissionsRepository from "../repositories/permissions.repository";
import { Permission } from "../interfaces/permissions.interface";

export const getAllPermissions = async (): Promise<Permission[]> => {
  return permissionsRepository.findAll();
};

export const createPermission = async (
  name: string,
  description: string | null
): Promise<Permission> => {
  const existing = await permissionsRepository.findByName(name);
  if (existing) {
    throw new Error("A permission with this name already exists");
  }
  return permissionsRepository.create(name, description);
};
