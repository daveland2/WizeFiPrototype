dataModelObjects =
{
	income:
	{
		label: 'Income',
		salary:
		{
			label: 'Salary',
			salary:
			{
				label: 'Salary',
				monthlyAmount: {val:0, inclusion:'required'},
			}
		},
		interest:
		{
			label: 'Interest',
			interest:
			{
				label: 'Interest',
				monthlyAmount: {val:0, inclusion:'required'}
			}
		}
	},
	expenses:
	{
		giving:
		{
			label: 'Giving',
			contributions:
			{
				label: 'Contributions',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			tithe:
			{
				label: 'Tithe',
				monthlyAmount: {val:0, inclusion:'required'}
			}
		},
		housing:
		{
			label: 'Housing',
			firstMortgage:
			{
				label: 'First Mortgage',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			secondMortgage:
			{
				label: 'Second Mortgage',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			otherLienPayment:
			{
				label: 'Other Lien Payment',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			rent:
			{
				label: 'Rent',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			homeOwnersInsurance:
			{
				label: 'Home Owners Insurance',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			propertyTaxes:
			{
				label: 'Property Taxes',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			homeMaintenance:
			{
				label: 'Home Maintenance',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			HOADues:
			{
				label: 'HOA Dues',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			housekeeping_Cleaning:
			{
				label: 'Housekeeping & Cleaning',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			water_Trash_Sewer:
			{
				label: 'Water/Trash/Sewer',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			gas_Electricity:
			{
				label: 'Gas & Electricity',
				monthlyAmount: {val:0, inclusion:'required'}
			}
		},
		transporation:
		{
			label: 'Transportation',
			payments:
			{
				label: 'Payments',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			insurance:
			{
				label: 'Insurance',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			gas:
			{
				label: 'Gas',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			maintenance:
			{
				label: 'Maintenance',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			registration:
			{
				label: 'Registration',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			RV_Payments:
			{
				label: 'RV Payments',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			RV_Insurance:
			{
				label: 'RV Insurance',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			RV_Gas:
			{
				label: 'RV Gas',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			RV_Maint:
			{
				label: 'RV Maint',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			RV_Registration:
			{
				label: 'RV Registration',
				monthlyAmount: {val:0, inclusion:'required'}
			}
		},
		food:
		{
			label: 'Food',
			groceries:
			{
				label: 'Groceries',
				monthlyAmount: {val:0, inclusion:'required'},
				field1: 'field1val',
				field2: 2
			},
			diningOut:
			{
				label: 'Dining Out',
				monthlyAmount: {val:0, inclusion:'required'}
			},
		},
		health_insurance:
		{
			label: 'Health Insurance',
			medicalPremium:
			{
				label: '',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			dentalPremium:
			{
				label: '',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			visionPremiums:
			{
				label: '',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			medicalCopay_Deductables:
			{
				label: 'Copay & Deductables',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			prescriptions:
			{
				label: 'Prescriptions',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			orthodontist:
			{
				label: 'Orthodontist',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			lifeInsurance:
			{
				label: 'Life Insurance',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			disabilityInsurance:
			{
				label: 'Disability Insurance',
				monthlyAmount: {val:0, inclusion:'required'}
			},
		},
		clothing:
		{
			label: 'Clothing',
			clothing:
			{
				label: 'Clothing',
				monthlyAmount: {val:0, inclusion:'required'}
			},
			laundry_Drycleaning:
			{
				label: 'Laundry/Dry Cleaning',
				monthlyAmount: {val:0, inclusion:'required'}
			},
		},
		entertainment:
		{
			label: 'Entertainment',
			entertainment:
			{
				label: 'Entertainment',
				monthlyAmount: {val:0, inclusion:'required'}
			}
		}
	},
	assets:
	{
		label: 'Assets',
		bankAccount:
		{
			label: 'Bank Account',
			checking:
			{
				label: 'Checking',
				accountOwner: {val:'', inclusion:'optional'},
				description: {val:'', inclusion:'required'},
				companyName: {val:'', inclusion:'optional'},
				accountValue: {val:'', inclusion:'required'},
				minimumMonthlyPayment: {val:0, inclusion:'optional'},
				rate: {val:0, inclusion:'optional'}
			},
			savings:
			{
				label: 'Savings',
				monthlyAmount: {val:100, inclusion:'required'},
				accountOwner: {val:'', inclusion:'optional'},
				description: {val:'', inclusion:'required'},
				companyName: {val:'', inclusion:'optional'},
				accountValue: {val:'', inclusion:'required'},
				minimumMonthlyPayment: {val:0, inclusion:'optional'},
				rate: {val:0, inclusion:'required'}
			}
		},
		taxAdvantaged:
		{
			label: 'Tax-Advantaged',
			rothIRA:
			{
				label: 'Roth IRA',
				monthlyAmount: {val:0, inclusion:'required'},
				accountOwner: {val:'', inclusion:'optional'},
				description: {val:'', inclusion:'required'},
				companyName: {val:'', inclusion:'optional'},
				accountValue: {val:'', inclusion:'required'},
				minimumMonthlyPayment: {val:0, inclusion:'optional'},
				employerContribution: {val:0, valType:'%', inclusion:'required'},
				rate: {val:0, inclusion:'required'}
			},
			simpleIRA:
			{
				label: 'Simple IRA',
				monthlyAmount: {val:0, inclusion:'required'},
				accountOwner: {val:'', inclusion:'optional'},
				description: {val:'', inclusion:'required'},
				companyName: {val:'', inclusion:'optional'},
				accountValue: {val:'', inclusion:'required'},
				minimumMonthlyPayment: {val:0, inclusion:'optional'},
				employerContribution: {val:0, valType:'%', inclusion:'required'},
				rate: {val:0, inclusion:'required'}
			}
		},
		CD:
		{
			label: 'CD',
			CD:
			{
				label: 'CD',
				monthlyAmount: {val:0, inclusion:'required'},
				accountOwner: {val:'', inclusion:'optional'},
				description: {val:'', inclusion:'required'},
				companyName: {val:'', inclusion:'optional'},
				accountValue: {val:'', inclusion:'required'},
				minimumMonthlyPayment: {val:0, inclusion:'optional'},
				rate: {val:0, inclusion:'required'},
				maturityDate: {val:'', inclusion:'required'},
			}
		}
	}
};  // dataModelObjects

dataModelObjects2 =
{
	assets:
	{
		label: 'Assets',
		bankAccount:
		{
			label: 'Bank Account',
			savings:
			{
				label: 'Savings',
				monthlyAmount: {label: 'Monthly Amount', val:200, inclusion:'required'},
				accountOwner: {label: 'Account Owner', val:'', inclusion:'optional'}
			}
		}
	}
};  // dataModelObjects2

dataModelArrays =
[
	{
		categoryName: 'Income',
		subcategories:
		[
			{
				subcategoryName: 'Salary',
				accounts:
				[
			    	{
			    		accountName: 'Salary',
			    		fields:
			    		[
			    			{monthlyAmount: {val:0, inclusion:'required'}}
			    		]
			    	}
			    ]
		    },
			{
				subcategoryName: 'Interest',
				accounts:
				[
			    	{
			    		accountName: 'Interest',
			    		fields:
			    		[
			    			{monthlyAmount: {val:0, inclusion:'required'}}
			    		]
			    	}
			    ]
			}
		]
	},
	{
		categoryName: 'assets',
		subcategories:
		[
			{
				subcategoryName: 'Bank Account',
				accounts:
				[
			    	{
			    		accountName: 'Checking',
			    		fields:
			    		[
							{accountOwner: {val:'', inclusion:'optional'}},
							{description: {val:'', inclusion:'required'}},
							{companyName: {val:'', inclusion:'optional'}},
							{accountValue: {val:'', inclusion:'required'}},
							{minimumMonthlyPayment: {val:0, inclusion:'optional'}},
							{rate: {val:0, inclusion:'optional'}}
			    		]
			    	},
			    	{
			    		accountName: 'Savings',
			    		fields:
			    		[
							{monthlyAmount: {val:300, inclusion:'required'}},
							{accountOwner: {val:'', inclusion:'optional'}},
							{description: {val:'', inclusion:'required'}},
							{companyName: {val:'', inclusion:'optional'}},
							{accountValue: {val:'', inclusion:'required'}},
							{minimumMonthlyPayment: {val:0, inclusion:'optional'}},
							{rate: {val:0, inclusion:'required'}}
			    		]
			    	}
			    ]
		    },
			{
				subcategoryName: 'Tax Advantaged',
				accounts:
				[
			    	{
			    		accountName: 'Roth IRA',
			    		fields:
			    		[
							{monthlyAmount: {val:0, inclusion:'required'}},
							{accountOwner: {val:'', inclusion:'optional'}},
							{description: {val:'', inclusion:'required'}},
							{companyName: {val:'', inclusion:'optional'}},
							{accountValue: {val:'', inclusion:'required'}},
							{minimumMonthlyPayment: {val:0, inclusion:'optional'}},
							{rate: {val:0, inclusion:'required'}},
			    		]
			    	}
			    ]
			}
		]
	}
];  // dataModelArrays

dataModelArrays2 =
[
	{
		categoryName: 'assets',
		subcategories:
		[
			{
				subcategoryName: 'Bank Account',
				accounts:
				[
			    	{
			    		accountName: 'Savings',
			    		fields:
			    		[
							{
								fieldName: 'Monthly Amount',
								field: {monthlyAmount: {val:400, inclusion:'required'}}
							},

							{
								fieldName: 'Account Owner',
								field: {accountOwner: {val:'', inclusion:'optional'}}
							}
			    		]
			    	}
			    ]
		    }
		]
	}
];  // dataModelArrays2

console.log('\nobject based access to information in assets category');

categoryName    = dataModelObjects['assets'].label;
subcategoryName = dataModelObjects['assets']['bankAccount'].label;
accountName     = dataModelObjects['assets']['bankAccount']['savings'].label;
monthlyAmount   = dataModelObjects['assets']['bankAccount']['savings']['monthlyAmount'].val;

console.log('categoryName: ' + categoryName);
console.log('subcategoryName: ' + subcategoryName);
console.log('accountName: ' +  accountName);
console.log('monthlyAmount: ' + monthlyAmount);


console.log('\nobject based access to information in assets category (with user friendly field names)');

monthlyAmountName = dataModelObjects2['assets']['bankAccount']['savings']['monthlyAmount'].label;
monthlyAmount     = dataModelObjects2['assets']['bankAccount']['savings']['monthlyAmount'].val;

console.log('monthlyAmountName: ' + monthlyAmountName);
console.log('monthlyAmount:     ' + monthlyAmount);


console.log('\narray based access to information in assets category');

categoryName    = dataModelArrays[1].categoryName;
subcategoryName = dataModelArrays[1]['subcategories'][0].subcategoryName;
accountName     = dataModelArrays[1]['subcategories'][0]['accounts'][1].accountName;
monthlyAmount   = dataModelArrays[1]['subcategories'][0]['accounts'][1]['fields'][0]['monthlyAmount'].val;

console.log('categoryName: ' + categoryName);
console.log('subcategoryName: ' + subcategoryName);
console.log('accountName: ' +  accountName);
console.log('monthlyAmount: ' + monthlyAmount);


console.log('\narray based access to information in assets category (with user friendly field names)');

monthlyAmountName = dataModelArrays2[0]['subcategories'][0]['accounts'][0]['fields'][0].fieldName;
monthlyAmount     = dataModelArrays2[0]['subcategories'][0]['accounts'][0]['fields'][0].field['monthlyAmount'].val;

console.log('monthlyAmountName: ' + monthlyAmountName);
console.log('monthlyAmount:     ' + monthlyAmount);

