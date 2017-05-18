import { IDataModel } from './data-model.service';

export const possibleFieldNames:any =
{
	accountOwner:         {label: 'Account Owner',          val:''},
	accountValue:         {label: 'Account Value',          val:0},
	monthlyAmount:        {label: 'Monthly Amount',         val:0},
	minimumMonthlyAmount: {label: 'Minimum Monthly Amount', val:0},
	employerContribution: {label: 'Employer Contribution',  val:0},
	growthRate:           {label: 'Growth Rate',            val:0},
	interestRate:         {label: 'Interest Rate',          val:0},
	coverageAmount:       {label: 'Coverage amount',        val:0},
	maturityDate:         {label: 'Maturity Date',          val:''},     // CD
	targetAmount:         {label: 'Target Amount',          val:0},      // required savings
	expirationYear:       {label: 'Expiration Year',        val:0},      // term life insurance
	appreciationRate:     {label: 'Appreciation Rate',      val:0},      // other (assets)
	depreciationRate:     {label: 'Depreciation Rate',      val:0},      // other (assets)
	creditCardLimit:      {label: 'Credit Card Limit',      val:0},      // credit card
	isPrimaryResidence:   {label: 'Primary Residence',      val:false},  // real estate assets
	isInvestmentProperty: {label: 'Investment Property',    val:false},  // real estate assets
	haveMortgage:         {label: 'Mortgage',               val:false},  // real estate assets
	haveSecondMortgage:   {label: 'Second Mortgage',        val:false},  // real estate assets
	haveLien:             {label: 'Lien',                   val:false},  // real estate assets
	haveLoan:             {label: 'Loan',                   val:false}   // real estate assets
	/*
	extraYouPay = monthlyPayment - minimumMonthlyPayment  // credit card  (incorporate this within monthlyAmount)

    // remove the following
	description:          {label: 'Description',            val:''}},
	companyName:          {label: 'Company Name',           val:''}},
	*/
};  // possibleFieldNames

/*
The following defines all possible account types (the JavaScript attribute name is the name of the type).  Each type is a distinct list of field names that are required for a particular account under a given subaccount.  The presence or absence of a field, and the value of the inclusion attribute are the things that distinguish one type from another.  (An absent field is the same as a field with inclusion N/A.)
*/
export const accountTypes =
{
	income:
	{
		monthlyAmount: {label: 'Monthly Amount', val:0, isRequired:true}
	},
	expenses:
	{
		monthlyAmount: {label: 'Monthly Amount', val:0, isRequired:true}
	},
	checking:
	{
		accountOwner:          {label: 'Account Owner',           val:'', isRequired:false},
		description:           {label: 'Description',             val:'', isRequired:true},
		companyName:           {label: 'Company Name',            val:'', isRequired:false},
		accountValue:          {label: 'Account Value',           val:0,  isRequired:true},
		minimumMonthlyPayment: {label: 'Minimum Monthly Payment', val:0,  isRequired:false},
		interestRate:          {label: 'Interest Rate',           val:0,  isRequired:false}
	},
	savingsRequired:
	{
		monthlyAmount:         {label: 'monthlyAmount',           val:0,  isRequired:true},
		accountOwner:          {label: 'Account Owner',           val:'', isRequired:false},
		description:           {label: 'Description',             val:'', isRequired:true},
		accountValue:          {label: 'Account Value',           val:0,  isRequired:true},
		minimumMonthlyPayment: {label: 'Minimum Monthly Payment', val:0,  isRequired:false},
		interestRate:          {label: 'Interest Rate',           val:0,  isRequired:false}
	},
	savingsOptional:
	{
		monthlyAmount:         {label: 'monthlyAmount',           val:0,  isRequired:false},
		accountOwner:          {label: 'Account Owner',           val:'', isRequired:false},
		description:           {label: 'Description',             val:'', isRequired:true},
		accountValue:          {label: 'Account Value',           val:0,  isRequired:true},
		minimumMonthlyPayment: {label: 'Minimum Monthly Payment', val:0,  isRequired:false},
		interestRate:          {label: 'Interest Rate',           val:0,  isRequired:false}
	},
	retirementAccount:
	{
		monthlyAmount:         {label: 'monthlyAmount',           val:0,  isRequired:true},
		accountType:           {label: 'Account Type',            val:'retirementAccount', isRequired:true},
		accountOwner:          {label: 'Account Owner',           val:'', isRequired:false},
		description:           {label: 'Description',             val:'', isRequired:true},
		companyName:           {label: 'Company Name',            val:'', isRequired:false},
		accountValue:          {label: 'Account Value',           val:0,  isRequired:true},
		minimumMonthlyPayment: {label: 'Minimum Monthly Payment', val:0,  isRequired:false},
		employerContribution:  {label: 'Employer Contribution',   val:0,  valType:'%', isRequired:false},  // keep valType?
		growthRate:            {label: 'Growth Rate',             val:0,  isRequired:false},
	},
	investments:
	{
		accountType:          {label: 'Account Type',          val:'investments', isRequired:true},
		monthlyAmount:        {label: 'Monthly Amount',        val:0,             isRequired:true},
		growthRate:           {label: 'Growth Rate',           val:0,             isRequired:true},
		accountValue:         {label: 'Account Value',         val:0,             isRequired:true},
		employerContribution: {label: 'Employer Contribution', val:0,             isRequired:false},
	},
	realEstate:
	{
		accountType:          {label: 'Account Type',          val:'realEstate', isRequired:true},
		monthlyAmount:        {label: 'Monthly Amount',        val:0,             isRequired:true},
	},
	insurance:
	{
		accountType:          {label: 'Account Type',          val:'realEstate', isRequired:true},
		monthlyAmount:        {label: 'Monthly Amount',        val:0,             isRequired:true},
	},
	creditCard:
	{
		accountType:          {label: 'Account Type',          val:'creditCard', isRequired:true},
		monthlyAmount:        {label: 'Monthly Amount',        val:0,             isRequired:true},
	},
	loan:
	{
		accountType: {label: 'Account Type',          val:'Loan', isRequired:true},
		monthlyAmount:        {label: 'Monthly Amount',        val:0,             isRequired:true},
	},
	//... others to come
};  // accountTypes


/*
The following defines account names and account types information under each subcategory.
*/
export const subcategoryInfo =
{
	income:
	{
		income:
		{
			accountNames:
			[
				'Salary',
				'Tips',
				'Alimony'
			],
			accountTypes: ['income']
		}
	},
	budget:
	{
		giving:
		{
			accountNames:
			[
				'Tithe',
				'Charitable Donations'
			],
			accountTypes: ['expenses']
		},
		housing:
		{
			accountNames:
			[
				'Mortgage',
				'Rent',
				'House Insurance',
				'Property Taxes',
				'Home Maintenance',
				'HOA Dues',
				'Housekeeping/Cleaning',
				'Electric',
				'Gas',
				'Water',
				'Trash',
				'Sewer'
			],
			accountTypes: ['expenses']
		},
		clothing:
		{
			accountNames:
			[
				'Clothing',
				'Laundry/Dry Cleaning'
			],
			accountTypes: ['expenses']
		},
		food:
		{
			accountNames:
			[
				'Groceries',
				'Dining Out'
			],
			accountTypes: ['expenses']
		},
		transportation:
		{
			accountNames:
			[
				'Auto Loan Payments',
				'R.V. Payments',
				'Auto Lease',
				'R.V. Lease',
				'Maintenance',
				'Gas',
				'Registration',
				'Auto Insurance',
				'R.V. Insurance'
			],
			accountTypes: ['expenses']
		},
		health:
		{
			accountNames:
			[
				'Medical Copays/Deductibles',
				'Prescriptions',
				'Orthodontist',
				'Optometrist'
			],
			accountTypes: ['expenses']
		},
		insurance:
		{
			accountNames:
			[
				'Life Insurance',
				'Medical Premiums',
				'Dental and Vision Premiums'
			],
			accountTypes: ['expenses']
		},
		entertainment:
		{
			accountNames:
			[
				'Vacations',
				'Hobbies',
				'Subscriptions',
				'Movies',
				'Concerts',
				'Theatre',
				'Cable'
			],
			accountTypes: ['expenses']
		},
		miscellaneous:
		{
			accountNames:
			[
				'Education',
				'Kids Activities',
				'Health Club/Tanning',
				'Grooming & Care',
				'Pets'
			],
			accountTypes: ['expenses']
		}
	},  // budget
	assets2:
	{
		checking:
		{
			accountNames:
			[
				'Checking Account'
			],
			accountTypes: ['checking']
		},
		savingsRequired:
		{
			accountNames:
			[
				'Emergency Savings',
				'General Savings'
			],
			accountTypes: ['savingsRequired']
		},
		savingsOptional:
		{
			accountNames:
			[
				'Savings Account'
			],
			accountTypes: ['savingsOptional']
		},
		investments:
		{
			accountNames:
			[
			   'IRA',
			   'Roth IRA',
			   'SEP IRA',
			   'Simple IRA',
			   '401(k)',
			   'Roth 401(k)',
			   '403(b)',
			   '457(b)',
			   'Pension',
			   'Annuity',
			   'HSA'
			],
			accountTypes: ['investments']
		},
		realEstate:
		{
			accountNames:
			[
				'Primary Residence',
				'Vacation Home',
				'Rental Property'
			],
			accountTypes: ['realEstate']
		}
	},  // assets2
	assetProtection:
	{
		insurance:
		{
			accountNames:
			[
			   'Term Life Insurance',
			   'Permanent Life Insurance',
			   'Group Life Insurance'
			],
			accountTypes: ['insurance']
		},
	},
	liabilities:
	{
		creditCard:
		{
			accountNames:
			[
		       'Credit Card'
			],
			accountTypes: ['creditCard']
		},
		loan:
		{
			accountNames:
			[
				'Auto Loan',
				'Personal Loan',
				'Student Loan'
			],
			accountTypes: ['loan']
		}
	}
};  // subcategoryInfo

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
				},  // assets
				assets2:
				{
					attributeName: 'assets2',
					label: 'Assets',
					savingsRequired:
					{
						label: 'Required Savings',
						accounts:
						[
							{
								accountName:   {label: 'Account Name',   val:'Emergency Savings', isRequired:true},
								accountType:   {label: 'Account Type',   val:'savingsRequired',   isRequired:true},
								isRequired:    {label: 'isRequired',     val:true,                isRequired:true},
								monthlyAmount: {label: 'Monthly Amount', val:0,                   isRequired:true},
								accountValue:  {label: 'Account Value',  val:0,                   isRequired:true},
								targetAmount:  {label: 'Target Amount',  val:0,                   isRequired:true}
							},
							{
								accountName:   {label: 'Account Name',   val:'General Savings', isRequired:true},
								accountType:   {label: 'Account Type',   val:'savingsRequired', isRequired:true},
								isRequired:    {label: 'isRequired',     val:true,              isRequired:true},
								monthlyAmount: {label: 'Monthly Amount', val:0,                 isRequired:true},
								accountValue:  {label: 'Account Value',  val:0,                 isRequired:true},
								targetAmount:  {label: 'Target Amount',  val:0,                 isRequired:true}
							}
						]
					},
					savingsOptional:
					{
						label: 'Optional Savings',
						accounts:
						[
							{
								accountName:   {label: 'Account Name',   val:'Mary Savings',    isRequired:true},
								accountType:   {label: 'Account Type',   val:'savingsOptional', isRequired:true},
								monthlyAmount: {label: 'Monthly Amount', val:0,                 isRequired:true},
								accountValue:  {label: 'Account Value',  val:0,                 isRequired:true}
							}
						]
					},
					investments:
					{
						label: 'Investments',
						accounts:
						[
							{
								accountName:          {label: 'Account Name',          val:'Joe IRA',     isRequired:true},
								accountType:          {label: 'Account Type',          val:'investments', isRequired:true},
								monthlyAmount:        {label: 'Monthly Amount',        val:0,             isRequired:true},
								growthRate:           {label: 'Growth Rate',           val:0,             isRequired:true},
								accountValue:         {label: 'Account Value',         val:0,             isRequired:true},
								employerContribution: {label: 'Employer Contribution', val:0,             isRequired:false},
							}
						]
					}
				}   // assets2
			},  // original
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
				},  // expenses
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
				},  // assets
				assets2:
				{
					attributeName: 'assets2',
					label: 'Assets',
					savingsRequired:
					{
						label: 'Required Savings',
						accounts:
						[
							{
								accountName:   {label: 'Account Name',   val:'Emergency Savings', isRequired:true},
								accountType:   {label: 'Account Type',   val:'savingsRequired',   isRequired:true},
								isRequired:    {label: 'isRequired',     val:true,                isRequired:true},
								monthlyAmount: {label: 'Monthly Amount', val:0,                   isRequired:true},
								accountValue:  {label: 'Account Value',  val:0,                   isRequired:true},
								targetAmount:  {label: 'Target Amount',  val:0,                   isRequired:true}
							},
							{
								accountName:   {label: 'Account Name',   val:'General Savings', isRequired:true},
								accountType:   {label: 'Account Type',   val:'savingsRequired', isRequired:true},
								isRequired:    {label: 'isRequired',     val:true,              isRequired:true},
								monthlyAmount: {label: 'Monthly Amount', val:0,                 isRequired:true},
								accountValue:  {label: 'Account Value',  val:0,                 isRequired:true},
								targetAmount:  {label: 'Target Amount',  val:0,                 isRequired:true}
							}
						]
					},
					savingsOptional:
					{
						label: 'Optional Savings',
						accounts:
						[
							{
								accountName:   {label: 'Account Name',   val:'Mary Savings',    isRequired:true},
								accountType:   {label: 'Account Type',   val:'savingsOptional', isRequired:true},
								monthlyAmount: {label: 'Monthly Amount', val:0,                 isRequired:true},
								accountValue:  {label: 'Account Value',  val:0,                 isRequired:true}
							},
						]
					},
					investments:
					{
						label: 'Investments',
						accounts:
						[
							{
								accountName:          {label: 'Account Name',          val:'Joe IRA',     isRequired:true},
								accountType:          {label: 'Account Type',          val:'investments', isRequired:true},
								monthlyAmount:        {label: 'Monthly Amount',        val:0,             isRequired:true},
								growthRate:           {label: 'Growth Rate',           val:0,             isRequired:true},
								accountValue:         {label: 'Account Value',         val:0,             isRequired:true},
								employerContribution: {label: 'Employer Contribution', val:0,             isRequired:false},
							}
						]
					}
				}   // assets2
			}   // current
		}
	}
};