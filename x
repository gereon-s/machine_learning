import pandas as pd
import statsmodels.api as sm
import numpy as np

# Function to run rolling regression
def rolling_regression(df, window_size, y_var, x_vars):
    """
    Perform a rolling OLS regression on the input DataFrame.
    
    Parameters:
    df: DataFrame containing the data
    window_size: the size of the rolling window (number of periods)
    y_var: the dependent variable (DXY)
    x_vars: a list of independent variables (e.g., Trump, FED_OIS)
    
    Returns:
    DataFrame of rolling beta coefficients for each independent variable
    """
    betas = pd.DataFrame(index=df.index, columns=x_vars)  # DataFrame to store betas

    # Loop through the DataFrame using a rolling window
    for i in range(window_size, len(df)):
        window_df = df.iloc[i-window_size:i]  # Get the data within the rolling window

        # Extract the dependent (y) and independent (X) variables
        y = window_df[y_var]
        X = window_df[x_vars]
        X = sm.add_constant(X)  # Add constant (intercept)

        # Run OLS regression
        model = sm.OLS(y, X).fit()

        # Store the beta coefficients
        betas.iloc[i] = model.params[1:]  # Store coefficients for Trump and FED_OIS (ignores intercept)

    return betas

# Load or use your merged_df
# merged_df should have columns 'DXY', 'Trump', 'FED_OIS'

# Define pre-FED and post-FED periods (assuming these are datetime or other sliceable indices)
pre_fed_df = merged_df.loc[pre_fed]  # Replace pre_fed with the actual slicing condition for pre-FED period
post_fed_df = merged_df.loc[post_fed]  # Replace post_fed with the actual slicing condition for post-FED period

# Set the rolling window size (e.g., 30 days)
window_size = 30

# Define the dependent and independent variables
y_var = 'DXY'
x_vars = ['Trump', 'FED_OIS']

# Run rolling regression for the pre-FED period
pre_fed_betas = rolling_regression(pre_fed_df, window_size, y_var, x_vars)

# Run rolling regression for the post-FED period
post_fed_betas = rolling_regression(post_fed_df, window_size, y_var, x_vars)

# Display the rolling betas
import ace_tools as tools; tools.display_dataframe_to_user(name="Pre-FED Betas", dataframe=pre_fed_betas)
tools.display_dataframe_to_user(name="Post-FED Betas", dataframe=post_fed_betas)


# Compute gamma (the first difference of the rolling betas) for pre-FED and post-FED periods
pre_fed_gamma = pre_fed_betas.diff().dropna()  # Drop NA values from diff calculation
post_fed_gamma = post_fed_betas.diff().dropna()  # Drop NA values from diff calculation

# Display gamma for both periods
tools.display_dataframe_to_user(name="Pre-FED Gamma (Change in Betas)", dataframe=pre_fed_gamma)
tools.display_dataframe_to_user(name="Post-FED Gamma (Change in Betas)", dataframe=post_fed_gamma)
