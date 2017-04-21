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