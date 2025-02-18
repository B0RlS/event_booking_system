# Event Booking System

## Introduction

Event Booking System is a robust and scalable Ruby on Rails application designed to handle event management and ticket booking with best development practices. The project leverages modern architectural patterns such as **Service Objects, Query Objects, Policy Objects, Decorators, and Event Sourcing** to ensure maintainability, scalability, and high performance.

The system supports user authentication via **Devise**, role-based access control using **Pundit**, caching strategies with **Redis**, and background processing. Additionally, the system is optimized for event-driven architecture using **dry-events** for Pub/Sub pattern implementation.

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

### 5. **Event Sourcing with Pub/Sub Pattern** *(Future Enhancement)*
   - Implement event-driven architecture using `dry-events`.
   - Allow asynchronous event propagation for better system scalability.
   - Can be extended for real-time notifications via **WebSockets**.

### 6. **Caching & Performance Optimizations**
- **Redis** caches frequently accessed data (events, tickets).
- **Background Jobs (Sidekiq)** for async tasks *(Future Enhancement)*.

### 7. **RESTful API & HTTP Standards**
- Standard HTTP methods (`GET, POST, PATCH, DELETE`).
- Consistent response formats with JSON.

### 8. **Form Object Pattern** *(Future Enhancement)*
   - Will be implemented for complex form handling, ensuring validation is handled separately from models.
   - Keeps controllers slim and ensures reusability.

### 9. **Dependency Injection Pattern** *(Future Enhancement)*
   - Improve modularity by injecting dependencies dynamically instead of hardcoding them.
   - Facilitates better testing and flexibility.

## System Design Improvements
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


