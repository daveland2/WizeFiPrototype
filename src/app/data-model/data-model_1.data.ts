import { IDataModel } from './data-model.service';

export const dataModel:IDataModel =
{
	global:
	{
		isLoggedIn: false,
		isNewUser: true,
		userID: '123',
		email: 'joe@abc.com',
		access_token: '12345',
		lambda: null
	},
	persistent:
	{
		header:
		{
			dataVersion: 1,
			dateCreated: '2017-04-05T12:14:32.456Z',
			dateUpdated: '2017-04-05T12:15:32.456Z',
			stripeCustomerID: '',
			stripeSubscriptionID: '',
			curplan: 'current',
		},
		settings:
		{
			currencyCode: '',
			thousandsSeparator: '',
			decimalSeparator: ''
		},
		profile:
		{
			name: '',
			age: 0
		},
		plans:
		{
			original:
			{
				budgetDetails:
				{
					housing: 0,
					food: 0
				},
				incomeDetails:
				{
					salary: 0,
					interest: 0
				},
				expenses:
				{
					giving:
					{
						label: 'Giving',
						contributions:
						{
							label: 'Contributions',
							monthlyAmount: 0,
							spuriousNumber: 25,
							spuriousString: 'testing'
						},
					},
					housing:
					{
						label: 'Housing',
						firstMortgage:
						{
							label: 'First Mortgage',
							monthlyAmount: 0
						},
						homeOwnersInsurance:
						{
							label: 'Home Owners Insurance',
							monthlyAmount: 0
						},
						propertyTaxes:
						{
							label: 'Property Taxes',
							monthlyAmount: 0
						},
						homeMaintenance:
						{
							label: 'Home Maintenance',
							monthlyAmount: 0
						},
						housekeeping_Cleaning:
						{
							label: 'Housekeeping & Cleaning',
							monthlyAmount: 0
						},
						water_Trash_Sewer:
						{
							label: 'Water/Trash/Sewer',
							monthlyAmount: 0
						},
						gas_Electricity:
						{
							label: 'Gas & Electricity',
							monthlyAmount: 0
						}
					}
				},
				assets:
				{
					bankAccount:
					{
						label: 'Bank Account',
						checking:
						{
							label: 'Checking',
							monthlyAmount: 0
						},
						savings:
						{
							label: 'Savings',
							monthlyAmount: 0
						}
					},
					taxable:
					{
						label: 'Taxable',
						brokerage:
						{
							label: 'Brokerage',
							monthlyAmount: 0
						},
						pension:
						{
							label: 'Pension',
							monthlyAmount: 0
						}
					},
					realEstate:
					{
						label: 'Real Estate',
						realEstate:
						{
							label: 'Real Estate',
							monthlyAmount: 0
						}
					},
				}
			},
			current:
			{
				budgetDetails:
				{
					housing: 0,
					food: 0
				},
				incomeDetails:
				{
					salary: 0,
					interest: 0
				},
				expenses:
				{
					giving:
					{
						label: 'Giving',
						contributions:
						{
							label: 'Contributions',
							monthlyAmount: 0,
							spuriousNumber: 25,
							spuriousString: 'testing'
						},
					},
					housing:
					{
						label: 'Housing',
						firstMortgage:
						{
							label: 'First Mortgage',
							monthlyAmount: 0
						},
						homeOwnersInsurance:
						{
							label: 'Home Owners Insurance',
							monthlyAmount: 0
						},
						propertyTaxes:
						{
							label: 'Property Taxes',
							monthlyAmount: 0
						},
						homeMaintenance:
						{
							label: 'Home Maintenance',
							monthlyAmount: 0
						},
						housekeeping_Cleaning:
						{
							label: 'Housekeeping & Cleaning',
							monthlyAmount: 0
						},
						water_Trash_Sewer:
						{
							label: 'Water/Trash/Sewer',
							monthlyAmount: 0
						},
						gas_Electricity:
						{
							label: 'Gas & Electricity',
							monthlyAmount: 0
						}
					}
				},
				assets:
				{
					bankAccount:
					{
						label: 'Bank Account',
						checking:
						{
							label: 'Checking',
							monthlyAmount: 0
						},
						savings:
						{
							label: 'Savings',
							monthlyAmount: 0
						}
					},
					taxable:
					{
						label: 'Taxable',
						brokerage:
						{
							label: 'Brokerage',
							monthlyAmount: 0
						},
						pension:
						{
							label: 'Pension',
							monthlyAmount: 0
						}
					},
					realEstate:
					{
						label: 'Real Estate',
						realEstate:
						{
							label: 'Real Estate',
							monthlyAmount: 0
						}
					}
				}
			}
		}
	}
};