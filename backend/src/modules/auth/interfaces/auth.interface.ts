import {
  DbPendingUser,
  DbUser,
  DbUserRegistrationResult,
  DbUserSummary,
} from "../types/auth.types";

export type IUser = DbUser;

export interface IJwtPayload {
  id: number;
  email: string;
  role: string;
}

type AuthUserWithoutPassword = Omit<DbUser, "password">;

export interface IAuthTokens {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
  user: AuthUserWithoutPassword;
}

export interface IAuthService {
  login(email: string, password: string): Promise<IAuthTokens>;
  register(
    name: string,
    email: string,
    password: string,
    roleId: number
  ): Promise<DbUserSummary>;
  createUserByAdmin(
    email: string,
    roleId: number,
    baseUrl: string
  ): Promise<DbPendingUser>;
  completeRegistration(
    token: string,
    fullName: string,
    password: string,
    passwordConfirm: string
  ): Promise<DbUserRegistrationResult>;
}
