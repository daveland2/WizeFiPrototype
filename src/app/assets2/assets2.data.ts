export const possibleAssets2 =
{
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
				employerContribution: {label: 'Employer Contribution', val:0,             isRequired:false}
			}
		]
	},
	insurance:
	{
		label: 'Insurance',
		accounts:
		[
			{
				accountName:    {label: 'Account Name',    val:'Life Insurance', isRequired:true},
				accountType:    {label: 'Account Type',    val:'insurance',      isRequired:true},
				monthlyAmount:  {label: 'Monthly Amount',  val:0,                isRequired:true},
				growthRate:     {label: 'Growth Rate',     val:0,                isRequired:false},
				accountValue:   {label: 'Account Value',   val:0,                isRequired:true},
				coverageAmount: {label: 'Coverage Amount', val:0,                isRequired:false}
			}
		]
	},
	realEstate:
	{
		label: 'Real Estate',
		accounts:
		[
			{
				accountName:          {label: 'Account Name',         val:'Joe House',  isRequired:true},
				accountType:          {label: 'Account Type',         val:'realEstate', isRequired:true},
				monthlyAmount:        {label: 'Monthly Amount',       val:0,            isRequired:true},
				minimumPayment:       {label: 'Minimum Payment',      val:0,            isRequired:true},
				interestRate:         {label: 'Interest Rate',        val:0,            isRequired:false},
				accountValue:         {label: 'Account Value',        val:0,            isRequired:true},
				isPrimaryResidence:   {label: 'isPrimaryResidence',   val:false,        isRequired:false},
				isInvestmentProperty: {label: 'isInvestmentProperty', val:false,        isRequired:false},
				haveMortgage:         {label: 'haveMortgage',         val:false,        isRequired:false},
				haveSecondMortgage:   {label: 'haveSecondMortgage',   val:false,        isRequired:false},
			}
		]
	},
	other:
	{
		label: 'Other',
		accounts:
		[
			{
				accountName:      {label: 'Account Name',      val:'Joe Account', isRequired:true},
				accountType:      {label: 'Account Type',      val:'other',       isRequired:true},
				monthlyAmount:    {label: 'Monthly Amount',    val:0,             isRequired:true},
				growthRate:       {label: 'Growth Rate',       val:0,             isRequired:false},
				appreciationRate: {label: 'Appreciation Rate', val:0,             isRequired:false},
				depreciationRate: {label: 'Depreciation Rate', val:0,             isRequired:false},
				accountValue:     {label: 'Account Value',     val:0,             isRequired:true}
			}
		]
	}
};
