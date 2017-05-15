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
};
