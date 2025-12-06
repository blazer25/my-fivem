RegisterNUICallback("JobCenter", function(data, cb)
    local action = data.action
    debugprint("JobCenter:" .. (action or ""))

    if action == "getJobs" then
        TriggerCallback("jobcenter:getJobs", cb)
    elseif action == "getCurrentJob" then
        TriggerCallback("jobcenter:getCurrentJob", cb)
    elseif action == "selectJob" then
        TriggerCallback("jobcenter:selectJob", cb, data.jobId)
    end
end)

RegisterNetEvent("phone:jobcenter:jobChanged", function(jobData)
    debugprint("phone:jobcenter:jobChanged:", jobData)
    SendReactMessage("jobcenter:jobChanged", jobData)
end)
