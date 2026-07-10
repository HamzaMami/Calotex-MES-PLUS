import * as productRepository from "../repositories/product.repository";
import { Product } from "../interfaces/product.interface";

export const getAllProducts = async (): Promise<Product[]> => {
  return await productRepository.findAll();
};

export const getProductById = async (id: number): Promise<Product | null> => {
  return await productRepository.findById(id);
};

export const createProduct = async (
  productData: Omit<Product, "id" | "created_at" | "updated_at">
): Promise<Product> => {
  return await productRepository.create(productData);
};

export const updateProduct = async (
  id: number,
  productData: Partial<Product>
): Promise<Product | null> => {
  return await productRepository.update(id, productData);
};

export const deleteProduct = async (id: number): Promise<boolean> => {
  return await productRepository.deleteProduct(id);
};
