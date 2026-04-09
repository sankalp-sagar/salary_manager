# Salary Manager Frontend

A React frontend for the Salary Management System.

## Features

- Employee CRUD operations
- Salary insights dashboard
- Authentication
- Responsive design

## Getting Started

1. Install dependencies:
   ```bash
   npm install
   ```

2. Start the development server:
   ```bash
   npm start
   ```

3. The app will run on http://localhost:3000

## Environment Variables

Create a `.env` file in the root directory:

```
REACT_APP_API_URL=http://localhost:3001
```

## Available Scripts

- `npm start` - Runs the app in development mode
- `npm run build` - Builds the app for production
- `npm test` - Runs the test suite
- `npm run eject` - Ejects from Create React App

## Project Structure

```
src/
├── components/     # Reusable components
├── pages/         # Page components
├── services/      # API services
└── utils/         # Utility functions
```