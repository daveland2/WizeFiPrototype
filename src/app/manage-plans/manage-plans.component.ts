import { Component, OnInit } from '@angular/core';

import { DataModelService } from '../data-model/data-model.service';

@Component(
{
	selector: 'app-manage-plans',
	templateUrl: './manage-plans.component.html',
	styleUrls: ['./manage-plans.component.css']
})
export class ManagePlansComponent implements OnInit
{
	selectedPlan: string;
	plans: string[] = [];
	messages: string[] = [];

	constructor(private dataModelService: DataModelService) { }

	ngOnInit()
	{
		// initialize list of plans
		this.plans = this.getPlanList();

		// select current plan that is in effect
		this.selectedPlan = this.dataModelService.dataModel.persistent.header.curplan;
	}   // ngOnInit

	getPlanList()
	{
		let result: string[] = [];
		for (let plan in this.dataModelService.dataModel.persistent.plans)
		{
			if (this.dataModelService.dataModel.persistent.plans.hasOwnProperty(plan))
			{
				result.push(plan);
			}
		}
		return result;
	}   // getPlanList

	clonePlan()
	{
		this.messages = [];
		let wantNewPlan = true;
		let newplan = prompt('Please enter name of new plan to be created');
		if (newplan == null)
		{
			wantNewPlan = false;
		}
		else
		{
			if (newplan == 'original')
			{
				wantNewPlan = false;
				this.messages.push('Plan name "original" is reserved');
			}
			else
			{
				if (this.plans.indexOf(newplan) != -1)
				{
					if (!confirm('Do you intend to overwrite the existing plan: ' + newplan))
					{
						wantNewPlan = false;
					}
				}
			}
		}
		if (!wantNewPlan)
		{
			this.messages.push('No change has been made');
		}
		else
		{
			// create a new "cloned" plan
			this.dataModelService.dataModel.persistent.plans[newplan] = JSON.parse(JSON.stringify(
				this.dataModelService.dataModel.persistent.plans[this.selectedPlan]));

			// update list of plans
			this.plans = this.getPlanList();

			// make the new plan the currently selected plan
			this.selectedPlan = newplan;
			this.dataModelService.dataModel.persistent.header.curplan = this.selectedPlan;
			this.messages.push('New plan named ' + newplan + ' has been created');
		}
	} // clonePlan

	deletePlan()
	{
		this.messages = [];
		let curplan = this.selectedPlan;
		if (curplan == 'original' || curplan == 'current') this.messages.push('Plan named "' + curplan + '" cannot be deleted');
		else
		{
			if (!confirm('Do you intend to delete the plan named ' + curplan))
			{
				this.messages.push('No change has been made');
			}
			else
			{
				// delete the plan
				delete this.dataModelService.dataModel.persistent.plans[curplan];

				// update list of plans
				this.plans = this.getPlanList();

				// reset the currently selected plan
				this.selectedPlan = 'current';
				this.dataModelService.dataModel.persistent.header.curplan = this.selectedPlan;
				this.messages.push('Plan named ' + curplan + ' has been deleted');
			}
		}
	}  // deletePlan

	// update data model
	update()
	{
		this.dataModelService.dataModel.persistent.header.curplan = this.selectedPlan;
	}

} // class ManagePlansComponent
