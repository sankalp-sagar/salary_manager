import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:3001';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('authToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    const response = error.response || {};
    console.error('API request failed:', response.status, response.data || error.message);
    return Promise.reject(response.data || error);
  }
);

class ApiService {
  async getEmployees(page = 1, perPage = 10) {
    const response = await apiClient.get(`/api/v1/employees?page=${page}&per_page=${perPage}`);
    return response.data;
  }

  async getEmployee(id) {
    const response = await apiClient.get(`/api/v1/employees/${id}`);
    return response.data.data;
  }

  async createEmployee(employeeData) {
    const response = await apiClient.post('/api/v1/employees', { employee: employeeData });
    return response.data.data;
  }

  async updateEmployee(id, employeeData) {
    const response = await apiClient.put(`/api/v1/employees/${id}`, { employee: employeeData });
    return response.data.data;
  }

  async deleteEmployee(id) {
    const response = await apiClient.delete(`/api/v1/employees/${id}`);
    return response.data;
  }

  async getSalaryInsightsByCountry() {
    const response = await apiClient.get('/api/v1/salary_insights/by_country');
    return response.data;
  }

  async getSalaryInsightsByJobTitleInCountry(country, jobTitle) {
    const params = new URLSearchParams({ country });
    if (jobTitle) params.append('job_title', jobTitle);
    const response = await apiClient.get(`/api/v1/salary_insights/by_job_title_in_country?${params}`);
    return response.data;
  }

  async getEmploymentByCountry() {
    const response = await apiClient.get('/api/v1/salary_insights/employment_by_country');
    return response.data;
  }

  async getTopJobTitles(limit = 10) {
    const response = await apiClient.get(`/api/v1/salary_insights/top_job_titles?limit=${limit}`);
    return response.data;
  }

  async login(email, password) {
    const response = await apiClient.post('/api/v1/login', { email, password });
    return response.data;
  }

  async refreshToken() {
    const response = await apiClient.post('/api/v1/refresh');
    return response.data;
  }

  async logout() {
    const response = await apiClient.delete('/api/v1/logout');
    return response.data;
  }
}

export default new ApiService();