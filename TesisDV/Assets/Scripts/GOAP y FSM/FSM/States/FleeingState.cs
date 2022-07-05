using System;
using FSM;

public class FleeingState : MonoBaseState
{
    public override void UpdateLoop()
    {
        
    }

     public override IState ProcessInput()
    {
       return this;
    }
}
