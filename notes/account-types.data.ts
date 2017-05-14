/*
The following defines all possible field names.
*/
possibleFieldNames =
[
	{accountOwner:         {label: 'Account Owner',          val:''}},
	{description:          {label: 'Description',            val:''}},
	{companyName:          {label: 'Company Name',           val:''}},
	{accountValue:         {label: 'Account Value',          val:0}},
	{monthlyAmount:        {label: 'Monthly Amount',         val:0}},
	{minimumMonthlyAmount: {label: 'Minimum Monthly Amount', val:0}},
	{employerContribution: {label: 'Employer Contribution',  val:0}},
	{growthRate:           {label: 'Growth Rate',            val:0}},
	{coverageAmount:       {label: 'Coverage amount',        val:0}},
	{maturityDate:         {label: 'Maturity Date',          val:''}},

	{targetAmount:         {label: 'Target Amount',          val:0}},
	/*
	targetAmount          // emergency and general savings
	expirationYear        // term life insurance
	isPrimaryResidence    // real estate assets
	isInvestmentProperty  // real estate assets
	haveMortgage          // real estate assets
	haveSecondMortgage    // real estate assets
	haveLien              // real estate assets
	haveLoanAgainstIRA    // IRA
	appreciationRate      // other (assets)  (also has Est. Growth Rate)
	extraYouPay           // credit card
	creditCardLimit       // credit card

	{isPrimaryResidence: {label: 'Primary Residence', val:true}}
	*/
];

/*
The following defines all possible account types (the JavaScript attribute name is the name of the type).  Each type is a distinct list of field names that are required for a particular account under a given subaccount.  The presence or absence of a field, and the value of the inclusion attribute are the things that distinguish one type from another.  (An absent field is the same as a field with inclusion N/A.)
*/
accountTypes =
{
	income:
	[
		{monthlyAmount: {label: 'Monthly Amount', val:0, isRequired:true}}
	],
	expenses:
	[
		{monthlyAmount: {label: 'Monthly Amount', val:0, isRequired:true}}
	],
	checking:
	[
		{accountOwner: {label: 'Account Owner', val:'', isRequired:false}},
		{description: {label: 'Description', val:'', isRequired:true}},
		{companyName: {label: 'Company Name', val:'', isRequired:false}},
		{accountValue: {label: 'Account Value', val:0, isRequired:true}},
		{minimumMonthlyPayment: {label: 'Minimum Monthly Payment', val:0, isRequired:false}},
		{rate: {label: 'Rate', val:0, isRequired:false}}
	],
	savingsRequired:
	[
		{monthlyAmount: {label: 'monthlyAmount', val:0, isRequired:true}},
		{accountOwner: {label: 'Account Owner', val:'', isRequired:false}},
		{description: {label: 'Description', val:'', isRequired:true}},
		{companyName: {label: 'Company Name', val:'', isRequired:false}},
		{accountValue: {label: 'Account Value', val:0, isRequired:true}},
		{minimumMonthlyPayment: {label: 'Minimum Monthly Payment', val:0, isRequired:false}},
		{rate: {label: 'Rate', val:0, isRequired:false}}
	],
	retirementAccount:
	[
		{monthlyAmount: {label: 'monthlyAmount', val:0, isRequired:true}},
		{accountOwner: {label: 'Account Owner', val:'', isRequired:false}},
		{description: {label: 'Description', val:'', isRequired:true}},
		{companyName: {label: 'Company Name', val:'', isRequired:false}},
		{accountValue: {label: 'Account Value', val:0, isRequired:true}},
		{minimumMonthlyPayment: {label: 'Minimum Monthly Payment', val:0, isRequired:false}},
		{employerContribution: {label: 'Employer Contribution', val:0, valType:'%', isRequired:false}},
		{rate: {label: 'Rate', val:0, isRequired:true}}
	]
	//... others to come
};  // accountTypes

/*
The following defines a list of account types associated with each subcategory.
*/
subcategoryAccountTypes =
{
	income:
	{
		income: ['income']
	},
	assets:
	{
		checking: ['checking'],
		savingsRequired: ['savingsRequired'],
		savingsOptional: ['savingsOptional'],
		investments: ['investments'],
		insurance: ['insurance'],
		realEstate: ['realEstate'],
		other: ['otherAsset']
	},
	liabilities:
	{
		creditCard: ['creditCard'],
		loans: ['loan']
	},
	budget:
	{
		giving: ['expenses'],
		housing: ['expenses'],
		clothing: ['expenses'],
		food: ['expenses'],
		transportation: ['expenses'],
		health: ['expenses'],
		insurance: ['expenses'],
		entertainment: ['expenses'],
		miscellaneous: ['expenses']
	}
};  // subcategoryAccountTypes

dataModel =
{
	income:
	{
		label: 'Income',
		income:
		{
			label: 'Income',
			accounts:
			[
				{
					accountName: 'Salary',
					accountType: 'income',
					monthlyAmount: {label: 'Monthly Amount', val:0, isRequired:true}
				},
				{
					accountName: 'Rent',
					accountType: 'income',
					monthlyAmount: {label: 'Monthly Amount', val:0, isRequired:true}
				}
			]
		}
	},
	assets:
	{
		label: 'Assets',
		savingsRequired:
		{
			label: 'Required Savings',
			accounts:
			[
				{
					accountName: 'Emergency Savings',
					accountType: 'savingsRequired',
					inclusion: 'required',
					monthlyAmount: {label: 'Monthly Amount', val:0, isRequired:true},
					accountValue:  {label: 'Account Value',  val:0, isRequired:true},
					targetAmount:  {label: 'Target Amount',  val:0, isRequired:true}
				},
				{
					accountName: 'General Savings',
					accountType: 'savingsRequired',
					inclusion: 'required',
					monthlyAmount: {label: 'Monthly Amount', val:0, isRequired:true},
					accountValue:  {label: 'Account Value',  val:0, isRequired:true},
					targetAmount:  {label: 'Target Amount',  val:0, isRequired:true}
				}
			]
		},
		savingsOptional:
		{
			label: 'Optional Savings',
			accounts:
			[
				{
					accountName: 'Mary Savings',
					accountType: 'savingsOptional',
					monthlyAmount: {label: 'Monthly Amount', val:0, isRequired:true},
					accountValue:  {label: 'Account Value',  val:0, isRequired:true}
				},
			]
		},
		investments:
		{
			label: 'Investments',
			accounts:
			[
				{
					accountName: 'Joe IRA',
					accountType: 'investments',
					monthlyAmount:        {label: 'Monthly Amount',        val:0, isRequired:true},
					growthRate:           {label: 'Growth Rate',           val:0, isRequired:true},
					accountValue:         {label: 'Account Value',         val:0, isRequired:true},
					employerContribution: {label: 'Employer Contribution', val:0, isRequired:false},
				}
			]
		}
	}   // assets
}

console.log('end test compile');
