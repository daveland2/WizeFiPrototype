export const possibleAssets2 =
{
	label: 'Assets2',
	savingsRequired:
	{
		label: 'Required Savings',
		accounts:
		[
			{
				accountName: 'Emergency Savings',
				accountType: 'savingsRequired',
				isRequired: true,
				monthlyAmount: {label: 'Monthly Amount', val:0, isRequired:true},
				accountValue:  {label: 'Account Value',  val:0, isRequired:true},
				targetAmount:  {label: 'Target Amount',  val:0, isRequired:true}
			},
			{
				accountName: 'General Savings',
				accountType: 'savingsRequired',
				isRequired: true,
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
};
