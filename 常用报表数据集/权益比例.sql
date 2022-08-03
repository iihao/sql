--关联权益比例字段
 LEFT JOIN dotnet_erp60..vxxmk_MultiTemplateProjectList qy
			ON qy.ProjGUID=r.ParentProjGUID
			
			
*qy.RightsRate/100 