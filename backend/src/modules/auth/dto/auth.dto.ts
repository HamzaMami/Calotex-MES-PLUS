export interface LoginRequestDTO {
  email: string;
  password: string;
}

export interface RegisterRequestDTO {
  name: string;
  email: string;
  password: string;
  roleId: number;
}

export interface LoginResponseDTO {
  access_token: string;
  refresh_token: string;
  expires_in: number;
  token_type: string;
  user: {
    id: number;
    name: string | null;
    email: string;
    role: string;
  };
}

export interface RefreshTokenDTO {
  refresh_token: string;
}

export interface RegisterResponseDTO {
  id: number;
  name: string;
  email: string;
  role: string;
}

// Admin creates user
export interface CreateUserByAdminDTO {
  email: string;
  roleId: number;
}

export interface CreateUserByAdminResponseDTO {
  id: number;
  email: string;
  role: string;
  status: string;
  message: string;
}

// User completes registration
export interface CompleteRegistrationDTO {
  fullName: string;
  password: string;
  passwordConfirm: string;
}

export interface CompleteRegistrationResponseDTO {
  id: number;
  name: string;
  email: string;
  role: string;
  message: string;
}
