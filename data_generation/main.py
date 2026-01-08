"""
Main script to generate all synthetic data for PulseMetrics
"""
import os
import sys
from datetime import datetime

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from config import *
from generators.users import generate_users, save_users
from generators.sessions import generate_sessions, save_sessions
from generators.events import generate_events, save_events
from generators.subscriptions import generate_subscriptions, save_subscriptions
from generators.payments import generate_payments, save_payments


def main():
    """
    Generate all synthetic datasets
    """
    print("\n" + "="*60)
    print("  PulseMetrics – Synthetic Data Generation")
    print("="*60 + "\n")
    
    # Create output directory if it doesn't exist
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    start_time = datetime.now()
    
    # Generate users
    print(f"[1/5] Generating {NUM_USERS:,} users...")
    users_df = generate_users(NUM_USERS, START_DATE, END_DATE, CHANNELS)
    save_users(users_df, OUTPUT_DIR)
    
    # Generate sessions
    print(f"\n[2/5] Generating sessions...")
    sessions_df = generate_sessions(
        users_df, 
        END_DATE, 
        SESSIONS_PER_ACTIVE_USER_MEAN, 
        SESSIONS_PER_ACTIVE_USER_STD
    )
    save_sessions(sessions_df, OUTPUT_DIR)
    
    # Generate events
    print(f"\n[3/5] Generating events...")
    events_df = generate_events(
        sessions_df, 
        EVENT_TYPES, 
        FEATURES,
        EVENTS_PER_SESSION_MEAN,
        EVENTS_PER_SESSION_STD
    )
    save_events(events_df, OUTPUT_DIR)
    
    # Generate subscriptions
    print(f"\n[4/5] Generating subscriptions...")
    subscriptions_df = generate_subscriptions(
        users_df,
        PLANS,
        END_DATE,
        TRIAL_CONVERSION_RATE,
        MONTHLY_CHURN_RATE,
        UPGRADE_PROBABILITY
    )
    save_subscriptions(subscriptions_df, OUTPUT_DIR)
    
    # Generate payments
    print(f"\n[5/5] Generating payments...")
    payments_df = generate_payments(
        subscriptions_df,
        PAYMENT_FAILURE_RATE,
        END_DATE
    )
    save_payments(payments_df, OUTPUT_DIR)
    
    # Summary
    elapsed = (datetime.now() - start_time).total_seconds()
    
    print("\n" + "="*60)
    print("  Summary")
    print("="*60)
    print(f"  Users:          {len(users_df):,}")
    print(f"  Sessions:       {len(sessions_df):,}")
    print(f"  Events:         {len(events_df):,}")
    print(f"  Subscriptions:  {len(subscriptions_df):,}")
    print(f"  Payments:       {len(payments_df):,}")
    print(f"\n  Time elapsed:   {elapsed:.2f} seconds")
    print(f"  Output dir:     {os.path.abspath(OUTPUT_DIR)}")
    print("="*60 + "\n")
    
    print("✓ Data generation complete!")
    print(f"  Next step: Load data into PostgreSQL using scripts in /warehouse\n")


if __name__ == "__main__":
    main()
