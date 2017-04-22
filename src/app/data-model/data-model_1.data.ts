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
					income:
					{
						income: 0
					},
					giving:
					{
						contributions: 0
					},
					housing:
					{
						firstMortgage: 0,
						homeOwnersInsurance: 0,
						propertyTaxes: 0,
						homeMaintenance: 0,
						housekeeping_Cleaning: 0,
						water_Trash_Sewer: 0,
						gas_Electricity: 0
					},
					transporation:
					{
						payments: 0,
						insurance: 0,
						gas: 0,
						maintenance: 0,
						registration: 0
					},
					food:
					{
						groceries: 0,
						diningOut: 0
					},
					health_insurance:
					{
						medicalPremium: 0,
						dentalPremium: 0,
						visionPremium: 0,
						prescriptions: 0,
						lifeInsurance: 0
					},
					clothing:
					{
						clothing: 0,
						laundry_Drycleaning: 0
					},
					savings_investment:
					{
						emergencyFund: 0,
						generalSavings: 0,
						checkingAccount: 0
					},
					entertainment:
					{
						entertainment: 0
					}
				},
				assets:
				{
					bankAccount:
					{
						checking: 0,
						savings: 0
					},
					cd:
					{
						cd: 0
					},
					taxable:
					{
						brokerage: 0,
						pension: 0
					},
					taxadvantaged:
					{
						IRA: 0,
						x401k: 0
					},
					realEstate:
					{
						realEstate: 0,
						lakeHouse: 0
					},
					personal:
					{
						personal: 0
					}
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
					income:
					{
						income: 0
					},
					giving:
					{
						contributions: 0
					},
					housing:
					{
						firstMortgage: 0,
						homeOwnersInsurance: 0,
						propertyTaxes: 0,
						homeMaintenance: 0,
						housekeeping_Cleaning: 0,
						water_Trash_Sewer: 0,
						gas_Electricity: 0
					},
					transporation:
					{
						payments: 0,
						insurance: 0,
						gas: 0,
						maintenance: 0,
						registration: 0
					},
					food:
					{
						groceries: 0,
						diningOut: 0
					},
					health_insurance:
					{
						medicalPremium: 0,
						dentalPremium: 0,
						visionPremium: 0,
						prescriptions: 0,
						lifeInsurance: 0
					},
					clothing:
					{
						clothing: 0,
						laundry_Drycleaning: 0
					},
					savings_investment:
					{
						emergencyFund: 0,
						generalSavings: 0,
						checkingAccount: 0
					},
					entertainment:
					{
						entertainment: 0
					}
				},
				assets:
				{
					bankAccount:
					{
						checking: 0,
						savings: 0
					},
					cd:
					{
						cd: 0
					},
					taxable:
					{
						brokerage: 0,
						pension: 0
					},
					taxadvantaged:
					{
						IRA: 0,
						x401k: 0
					},
					realEstate:
					{
						realEstate: 0,
						lakeHouse: 0
					},
					personal:
					{
						personal: 0
					}
				}
			}
		}
	}
};