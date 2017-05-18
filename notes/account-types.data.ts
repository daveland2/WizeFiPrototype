/*
The following defines all possible field names.
*/
possibleFieldNames:any =
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
accountTypes =
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
	retirementAccount:
	{
		monthlyAmount:         {label: 'monthlyAmount',           val:0,  isRequired:true},
		accountOwner:          {label: 'Account Owner',           val:'', isRequired:false},
		description:           {label: 'Description',             val:'', isRequired:true},
		companyName:           {label: 'Company Name',            val:'', isRequired:false},
		accountValue:          {label: 'Account Value',           val:0,  isRequired:true},
		minimumMonthlyPayment: {label: 'Minimum Monthly Payment', val:0,  isRequired:false},
		employerContribution:  {label: 'Employer Contribution',   val:0,  valType:'%', isRequired:false},  // keep valType?
		growthRate:            {label: 'Growth Rate',             val:0,  isRequired:false},
	}
	//... others to come
};  // accountTypes

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
