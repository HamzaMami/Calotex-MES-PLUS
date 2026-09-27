import * as usersRepository from "../repositories/users.repository";
import * as authRepository from "../../auth/repositories/auth.repositories";
import * as tokenUtils from "../../auth/utils/token.utils";
import { UserWithRole } from "../interfaces/users.interface";
import { sendEmail, generateRegistrationEmail } from "../../../shared/services/email.service";

export const getAllUsers = async (page?: number, limit?: number) => {
  return usersRepository.findAll(page, limit);
};

export const getUserById = async (id: number): Promise<UserWithRole | null> => {
  return usersRepository.findById(id);
};

export const createUser = async (
  name: string,
  email: string,
  roleId: number,
  baseUrl: string
): Promise<UserWithRole> => {
  const existing = await usersRepository.findByEmail(email);
  if (existing) {
    throw new Error("Email already in use");
  }

  const { token, expiresAt } = tokenUtils.generateRegistrationToken();
  await authRepository.createPendingUser(email, roleId, token, expiresAt);

  const registrationLink = `${baseUrl}/complete-registration/${token}`;
  const emailHtml = generateRegistrationEmail(name, registrationLink);
  await sendEmail({
    to: email,
    subject: "Complete Your Registration - Calotex MES",
    html: emailHtml,
  });

  const created = await usersRepository.findByEmail(email);
  return created!;
};

export const updateUser = async (
  id: number,
  fields: { name?: string; role_id?: number | null; status?: string }
): Promise<UserWithRole> => {
  const user = await usersRepository.findById(id);
  if (!user) throw new Error("User not found");
  const updated = await usersRepository.updateUser(id, fields);
  return updated!;
};

export const setUserStatus = async (
  id: number,
  status: string
): Promise<void> => {
  const user = await usersRepository.findById(id);
  if (!user) throw new Error("User not found");
  await usersRepository.setStatus(id, status);
};

export const deleteUser = async (id: number): Promise<void> => {
  const user = await usersRepository.findById(id);
  if (!user) throw new Error("User not found");
  await usersRepository.remove(id);
};
