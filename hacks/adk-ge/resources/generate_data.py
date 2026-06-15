import csv
import random
from datetime import datetime, timedelta

def generate_data(filename, num_records=100):
    products = ['Gold Saver', 'Student Account', 'Business Plus', 'Fixed Deposit']
    names = ['John Doe', 'Jane Smith', 'Alice Johnson', 'Bob Brown', 'Charlie Davis', 'Eve White', 'Frank Miller', 'Grace Hopper', 'Henry Ford', 'Ivy League']
    emails = ['john.doe@example.com', 'jane.smith@test.org', 'alice.j@corp.net', 'bob.b@gmail.com', 'charlie.d@yahoo.com']
    
    with open(filename, 'w', newline='') as csvfile:
        fieldnames = ['account_id', 'customer_id', 'pii_name', 'pii_email', 'pii_phone', 'balance', 'open_date', 'product_type']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        
        for i in range(num_records):
            account_id = f'ACC{1000 + i}'
            customer_id = f'CUST{500 + (i % 10)}'
            name = names[i % len(names)]
            email = emails[i % len(emails)]
            phone = f'+1-555-{random.randint(100, 999)}-{random.randint(1000, 9999)}'
            balance = round(random.uniform(1000, 50000), 2)
            open_date = (datetime.now() - timedelta(days=random.randint(1, 3650))).strftime('%Y-%m-%d')
            product_type = random.choice(products)
            
            writer.writerow({
                'account_id': account_id,
                'customer_id': customer_id,
                'pii_name': name,
                'pii_email': email,
                'pii_phone': phone,
                'balance': balance,
                'open_date': open_date,
                'product_type': product_type
            })

if __name__ == '__main__':
    generate_data('bank_data.csv')
    print("bank_data.csv generated successfully.")
