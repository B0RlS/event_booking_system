# Event Booking System

## Introduction

Event Booking System is a robust and scalable Ruby on Rails application designed to handle event management and ticket booking with best development practices. The project leverages modern architectural patterns such as **Service Objects, Query Objects, Policy Objects, Decorators** and State Machine to ensure maintainability, scalability, and high performance.

The system supports user authentication via **Devise**, role-based access control using **Pundit**, caching strategies with **Redis**.

---

## **Use Cases (How the System Works)**

### **1. Guest (Unauthenticated User)**
- Can **view all events** (`GET /api/v1/events`).
- Can **view details of a specific event** (`GET /api/v1/events/:id`).
- **Cannot** book tickets.

### **2. Regular User (Role: `user`)**
- Can do everything a guest can.
- Can **book a ticket for an event** (`POST /api/v1/events/:event_id/tickets`).
- Can **view their booked tickets** (`GET /api/v1/tickets`).
- Can **view details of a specific ticket** (`GET /api/v1/tickets/:id`).
- Can **cancel their booked tickets** (`DELETE /api/v1/tickets/:id`).

### **3. Manager (Role: `manager`)**
- Can do everything a regular user can.
- Can **create events** (`POST /api/v1/manager/events`).
- Can **edit events** (`PATCH /api/v1/manager/events/:id`).
- Can **cancel events** (`DELETE /api/v1/manager/events/:id`).
- Can **view all booked tickets for their events** (`GET /api/v1/manager/events/:event_id/tickets`).

### **4. Automatic Ticket Cancellation when an Event is Deleted**
- If a manager **cancels an event**, all booked and pending tickets for that event are **automatically canceled**.
- This prevents users from having active tickets for non-existent events.

### **5. Additional useful features**
- Protection events from overbooking (Users can't book more tickets that event has)
- Multiply selection tickets for cancellation (possible to cancel different tickets form different events)
- Multiply tickets booking, user can book more then one ticket but no more then availible tickets count
- Error handling and validations to protect system form bad requests
- Policy usage for permissions
- Decorated data for freindly and comfortable information
- Money gem usage for working and extending system to work with payment in future and different currencies

---

## **Backend Functionality & System Behavior**
### **Event & Ticket State Transitions (FSM - Finite State Machine)**
- **Events** have the following states:
  - `active` (initial)
  - `finished` (after event time ends)
  - `cancelled` (when deleted by a manager)
- **Tickets** have the following states:
  - `pending` (initial)
  - `booked` (after confirmation)
  - `cancelled` (user-initiated or event cancellation)

### **Caching Strategy**
- **Events & Tickets** are cached using **Redis** to reduce database queries.
- Cached data is automatically **cleared** when events or tickets are updated.

### **Security & Access Control**
- Uses **Devise** for user authentication.
- Implements **Pundit Policies** for role-based access control.
- Regular users cannot access manager-specific endpoints.
- Users can only **view and cancel** their own tickets.
- Managers can only **manage events they created**.

### **Query Optimization and Database**
- Uses **Query Objects** to handle complex database queries efficiently.
- Reduces **N+1 queries** by preloading associated models.
- ACID

### **Searching and Filtering**
- Using **Query Objects** we have optimized code to filter and sort data

### **Error Handling & Transaction Management**
- **Service Objects** wrap business logic, ensuring a clean and reusable structure.
- **ActiveRecord Transactions** prevent data inconsistencies during booking and cancellations.
- **ServiceResult Pattern** standardizes error handling across the system.


## API Endpoints
### Authentication (Devise)
- `POST /users/sign_in` – User login
- `DELETE /users/sign_out` – User logout
- `POST /users` – User registration
  
### Public Endpoints
#### Events
- `GET /api/v1/events` – Retrieve all available events
- `GET /api/v1/events/:id` – Retrieve details of a specific event

### User Endpoints
#### Tickets
- `GET /api/v1/tickets` – Get all tickets booked by the user
- `GET /api/v1/tickets/:id` – Get details of a specific ticket
- `POST /api/v1/events/:event_id/tickets` – Book tickets for an event
- `DELETE /api/v1/tickets/:id` – Cancel a ticket

### Manager Endpoints
#### Events
- `POST /api/v1/manager/events` – Create an event
- `PATCH /api/v1/manager/events/:id` – Update an event
- `DELETE /api/v1/manager/events/:id` – Cancel an event
#### Tickets
- `GET /api/v1/manager/events/:event_id/tickets` – Get all booked and cancelled tickets for a managed event

## Setup and Installation
### Prerequisites
- Ruby 3.2.2
- Rails 7.1.5
- PostgreSQL
- Redis
- Bundler

### Installation Steps
1. Clone the repository:
   ```sh
   git clone https://github.com/B0RlS/event-booking-system.git
   cd event-booking-system
   ```
2. Install dependencies:
   ```sh
   bundle install
   ```
3. Setup the database:
   ```sh
   rails db:create db:migrate db:seed
   ```
4. Start the server:
   ```sh
   rails s
   ```

## Design Patterns and Best Practices Used
### 1. **Service Object Pattern**
   - Encapsulates business logic in dedicated service classes (e.g., `Events::Create`, `Tickets::Booking`...).
   - Ensures single responsibility and reusability.
   
### 2. **Query Object Pattern**
   - Encapsulates complex queries into dedicated classes (e.g., `Queries::Event`, `Queries::Ticket`).
   - Improves code readability and maintains query logic separate from models.
   
### 3. **Policy Object Pattern**
   - Used for role-based access control (e.g., `EventPolicy`, `TicketPolicy`).
   - Ensures security and maintains clear authorization logic.

### 4. **Decorator Pattern**
   - Used for formatting data presentation via `Draper` (e.g., `EventDecorator`, `TicketDecorator`).
   - Keeps view logic separate from models and controllers.

### 5. **Caching & Performance Optimizations**
- **Redis** caches frequently accessed data (events, tickets).
- **Background Jobs (Sidekiq)** for async tasks *(Future Enhancement)*.

### 6. **RESTful API & HTTP Standards**
- Standard HTTP methods (`GET, POST, PATCH, DELETE`).
- Consistent response formats with JSON.

### 7. **Form Object Pattern** *(Future Enhancement)*
   - Will be implemented for complex form handling, ensuring validation is handled separately from models.
   - Keeps controllers slim and ensures reusability.

### 8. **Dependency Injection Pattern** *(Future Enhancement)*
   - Improve modularity by injecting dependencies dynamically instead of hardcoding them.
   - Facilitates better testing and flexibility.

### 9. **Pub/Sub Pattern** *(Future Enhancement)*
   - Improve events handling and notifications (more info below)

## System Design Improvements
### 0. **Removing Role module**
   - After fresh review I got that its better to move this logic to User table (for this tipe of task)

### 1. **Scaling via Load Balancer & CDN**
   - Implement **NGINX or AWS ELB** for request distribution.
   - Use **Cloudflare or AWS CloudFront** for caching static assets.

### 2. **Database Replication & Optimization**
   - Implement **PostgreSQL read replicas** to balance load.
   - Utilize **partitioning and indexing** for faster queries.

### 3. **Asynchronous Processing with Background Jobs**
   - Use **Sidekiq or ActiveJob** to process ticket booking/cancellation.
   - Improve API response times by handling long-running tasks in the background.

### 4. **Real-time Updates & Notifications with Pub/Sub**
   - Implement WebSockets or **ActionCable** to provide real-time event notifications.
   - Extend **dry-events** to broadcast event changes to multiple subscribers.
   - Introduce **Kafka or RabbitMQ** for a more scalable event processing system.

### 5. **Monitoring & Logging System**
   - Implement **Prometheus + Grafana** for application metrics.
   - Use **Logstash + Kibana** for centralized logging and error tracking.
   - Integrate **Sentry or Rollbar** for real-time error monitoring.

### 6. Load Balancer & Cloud Deployment
- **Nginx** as a load balancer.
- **AWS** for scalability.
- **CDN** for asset delivery.

### 7. Database & Caching
- **PostgreSQL** with read replicas for scaling.


## Future Enhancements
### **Functional Improvements**
- **Dynamic Ticket Pricing:** Adjust ticket prices dynamically based on availability.
- **Event & Ticket Reports:** Generate analytics for event organizers.
- **Subscriptions for Events:** Users can follow event organizers and get notifications.
- **More User Roles:** Add intermediate roles for event organizers.
- **Sorting & Filtering:** Use implemented Query Object for sorting and filtering.
- **Currency Exchange Integration:** Support external API for currency conversion.
- **Refunds & Ticket Returns:** Enable users to return tickets with refund processing.
- **Advanced Ticket States:** Introduce more granular states like `waiting list`.
- **Management System for Organizers:** A dedicated dashboard for event managers.
- **Auto-Completion for Events:** Mark events as `finished` when they reach their end time.

### **Architectural Enhancements**
- **Monitoring & Logging:** Improve system observability.
- **CI/CD Integration:** Automate testing and deployment.
- **Dockerization:** Containerize the application for better portability.
- **Localization Support:** Multi-language support for international users.
- **Advanced Form Handling:** Use **dry-rb Form Objects** for cleaner data processing.
- **Security Improvements:** Implement **JWT authentication** for API security.

## Testing Strategy Improvements
- **Expand Unit & Integration Tests:** Increase test coverage for services.
- **Add UI Tests:** Implement **Cypress or Selenium** for end-to-end testing.
- **Test Performance & Scalability:** Simulate high traffic and optimize bottlenecks for 3000+ RPS.

## Conclusion
This project is built following industry best practices and modern design patterns, ensuring **maintainability, scalability, and high performance**. Future enhancements will introduce **real-time notifications, advanced monitoring, and a subscription model**, making it a fully-fledged event management system.

If you have any questions, please reach out! 🚀


