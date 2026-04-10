# Salary Manager

A full-stack salary management application built for the assessment.
It includes a Rails API backend and a React frontend with employee CRUD, analytics dashboards, authentication, and seeded data.

## Setup

### Prerequisites
- Ruby 3.4.2
- PostgreSQL
- Node.js (recommended 18+)
- Yarn or npm

### Backend setup
```bash
bundle install
cp config/database.yml.example config/database.yml # if needed
rails db:create db:migrate db:seed
```

### Frontend setup
```bash
cd frontend
npm install
```

### Run the backend
```bash
rails server -p 3001
```
In another terminal:
```bash
cd frontend
npm start
```

### API URL configuration
If the frontend needs a custom API URL, set `REACT_APP_API_URL` in a `.env` file or environment.

## Technologies used
- Rails 8.1 API backend
- PostgreSQL database
- JWT authentication
- React 19 frontend
- Axios for API calls
- Recharts for interactive charts
- RSpec for Rails tests

## Design notes
- Backend exposes authenticated employee CRUD and salary analytics endpoints.
- Frontend provides a responsive dashboard, employee list, edit/create form, and salary insights charts.
- The salary insights page visualizes country salary ranges, employment status, and top job titles.
- Seed script generates 10,000 realistic employees with job titles, countries, salaries, and active/former status.

## Default credential
- HR user: `hr@test.com` / `password`


## App architecture 
- Routes are namespaced under api/v1
- Controllers returns JSON responses
- JWT access tokens are used for auth
- Tokens are automatically refreshed
- Any api access requires authentication via HR login
