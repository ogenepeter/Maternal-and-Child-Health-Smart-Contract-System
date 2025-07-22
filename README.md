# Maternal and Child Health Smart Contract System

A comprehensive blockchain-based system for managing maternal and child health services, ensuring coordinated care from pregnancy through early childhood.

## System Overview

This system consists of five interconnected smart contracts that work together to provide comprehensive maternal and child health services:

### 1. Prenatal Care Coordination Contract (`prenatal-care.clar`)
- Manages prenatal appointments and care schedules
- Tracks prenatal visits and ensures consistent care
- Monitors high-risk pregnancies
- Coordinates between healthcare providers

### 2. Birth Outcome Tracking Contract (`birth-outcomes.clar`)
- Records birth details and outcomes
- Tracks maternal and infant health metrics
- Monitors complications and interventions
- Generates outcome reports for quality improvement

### 3. Vaccination Schedule Management Contract (`vaccination-schedule.clar`)
- Manages childhood immunization schedules
- Tracks vaccination records and due dates
- Sends reminders for upcoming vaccinations
- Ensures compliance with recommended schedules

### 4. Nutrition Support Contract (`nutrition-support.clar`)
- Provides nutritional assistance programs
- Tracks nutritional status of mothers and children
- Manages food assistance distribution
- Monitors nutritional outcomes

### 5. Postpartum Depression Screening Contract (`postpartum-screening.clar`)
- Conducts regular mental health screenings
- Identifies at-risk mothers
- Coordinates mental health support services
- Tracks treatment outcomes

## Key Features

- **Decentralized Health Records**: Secure, immutable health records on the blockchain
- **Care Coordination**: Seamless coordination between different healthcare services
- **Automated Reminders**: Smart contract-based reminder system for appointments and screenings
- **Outcome Tracking**: Comprehensive tracking of health outcomes for quality improvement
- **Privacy Protection**: Patient data protection with controlled access mechanisms

## Technical Architecture

### Data Types
- Patient records with unique identifiers
- Appointment and visit tracking
- Health outcome measurements
- Vaccination records and schedules
- Nutritional assessment data
- Mental health screening results

### Access Control
- Healthcare provider permissions
- Patient consent management
- Administrative oversight capabilities
- Emergency access protocols

### Error Handling
- Comprehensive error codes for all operations
- Input validation and sanitization
- State consistency checks
- Recovery mechanisms

## Installation

1. Install Clarinet CLI
2. Clone this repository
3. Run `clarinet check` to validate contracts
4. Run `npm test` to execute test suite
5. Deploy using `clarinet deploy`

## Usage

Each contract provides specific functions for managing different aspects of maternal and child health:

- Register patients and healthcare providers
- Schedule and track appointments
- Record health outcomes and measurements
- Manage vaccination schedules
- Conduct screenings and assessments
- Generate reports and analytics

## Testing

The system includes comprehensive tests using Vitest:
- Unit tests for each contract function
- Integration tests for cross-contract workflows
- Edge case and error condition testing
- Performance and gas optimization tests

## Security Considerations

- Input validation on all public functions
- Access control for sensitive operations
- Data privacy and confidentiality measures
- Audit trails for all transactions
- Emergency procedures for critical situations

## Contributing

Please read the PR-DETAILS.md file for contribution guidelines and development standards.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
