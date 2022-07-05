using System;
using FSM;

public class ChaseCatState : MonoBaseState
{
    public override void UpdateLoop()
    {
        
    }

     public override IState ProcessInput()
    {
       return this;
    }
}
