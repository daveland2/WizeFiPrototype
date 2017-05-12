/*
The following defines all possible field names:
*/
export const possibleFieldNames =
[
	{accountOwner:         {label: 'Account Owner',          val:''}},
	{description:          {label: 'Description',            val:''}},
	{companyName:          {label: 'Company Name',           val:''}},
	{accountValue:         {label: 'Account Value',          val:0}},
	{monthlyAmount:        {label: 'Monthly Amount',         val:0}},
	{minimumMonthlyAmount: {label: 'Minimum Monthly Amount', val:0}},
	{employerContribution: {label: 'Employer Contribution',  val:0}},
	{growthRate:           {label: 'Growth Rate',            val:0}}
	/*
	targetAmount          // emergency and general savings
	maturityDate          // CD
	coverageAmount        // term, permanent, and group life insurance
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
The following defines all possible field types (the JavaScript attribute name is the name of the type).  Each type is a distinct list of field names that are required for a particular account under a given subaccount.  The presence or absence of a field, and the value of the inclusion attribute are the things that distinguish one type from another.  (An absent field is the same as a field with inclusion N/A.)
*/
export const fieldTypes =
{
	income:
	[
		{monthlyAmount: {label: 'Monthly Amount', val:0, inclusion:'required'}}
	],
	expenses:
	[
		{monthlyAmount: {label: 'Monthly Amount', val:0, inclusion:'required'}}
	],
	checking:
	[
		{accountOwner: {label: 'Account Owner', val:'', inclusion:'optional'}},
		{description: {label: 'Description', val:'', inclusion:'required'}},
		{companyName: {label: 'Company Name', val:'', inclusion:'optional'}},
		{accountValue: {label: 'Account Value', val:0, inclusion:'required'}},
		{minimumMonthlyPayment: {label: 'Minimum Monthly Payment', val:0, inclusion:'optional'}},
		{rate: {label: 'Rate', val:0, inclusion:'optional'}}
	],
	savings:
	[
		{monthlyAmount: {label: 'monthlyAmount', val:0, inclusion:'required'}},
		{accountOwner: {label: 'Account Owner', val:'', inclusion:'optional'}},
		{description: {label: 'Description', val:'', inclusion:'required'}},
		{companyName: {label: 'Company Name', val:'', inclusion:'optional'}},
		{accountValue: {label: 'Account Value', val:0, inclusion:'required'}},
		{minimumMonthlyPayment: {label: 'Minimum Monthly Payment', val:0, inclusion:'optional'}},
		{rate: {label: 'Rate', val:0, inclusion:'optional'}}
	]
	retirementAccount:
	{
		monthlyAmount: {label: 'monthlyAmount', val:0, inclusion:'required'},
		accountOwner: {label: 'Account Owner', val:'', inclusion:'optional'},
		description: {label: 'Description', val:'', inclusion:'required'},
		companyName: {label: 'Company Name', val:'', inclusion:'optional'},
		accountValue: {label: 'Account Value', val:0, inclusion:'required'},
		minimumMonthlyPayment: {label: 'Minimum Monthly Payment', val:0, inclusion:'optional'},
		employerContribution: {label: 'Employer Contribution', val:0, valType:'%', inclusion:'optional'},
		rate: {label: 'Rate', val:0, inclusion:'required'}
	},

	//... others to come
};  // accountTypes

/*
The following defines a list of account types associated with each subcategory.
(Hierarchical form of data is group, category, subcategory.)
*/
export const subcategoryAccountTypes =
{
	income:
	{
		income:
		{
			takehomePay: ['income'],
			selfEmployment: ['income'],
			hobby: ['income'],
			socialSecurity: ['income']
		}
	},
	budget:
	{
		giving:
		{
			tithe: ['expenses'],
			contributions: ['expenses']
		},
		housing:
		{
			propertyTaxes: ['expenses'],
			homeMaintenance: ['expenses'],
			housekeeping_Cleaning: ['expenses'],
			water_Trash_Sewer: ['expenses'],
			gas_Electricity: ['expenses']
		}
	},
	assets:
	{

	}
};  // subcategoryAccountTypes
